#!/usr/bin/env python
#
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""An Apache Beam streaming pipeline example.

It reads JSON encoded messages from Pub/Sub, transforms the message data and
writes the results to BigQuery.
"""

import argparse
import json
import logging
import time
from typing import Any, Dict, List

import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
import apache_beam.transforms.window as window

# Defines the BigQuery schema for the output table.
SCHEMA = ",".join(
    [
        "age:INTEGER",
        "sex:STRING",
        "bmi:FLOAT64",
        "children:INTEGER",
        "smoker:BOOL",
        "region:STRING",
        "charges:FLOAT64",
    ]
)


def parse_json_message(message: str) -> Dict[str, Any]:
    """Parse the input json message"""
    row = json.loads(message)
    
    # # once I define my own pipeline template I will have it skip the headerlines when it reads in the csv data
    # if row=='age,sex,bmi,children,smoker,region,charges':
    #     return Undefined # tell dataflow to skip the record, this is the header
    # # validate line isn't missing data 
    # if row.length < 7:
    #     return Undefined # tell dataflow to skip record
    
    return {
        "age": int(row["age"]),
        "sex": row["sex"],
        "bmi": float(row["bmi"]),
        "children": int(row["children"]),
        "smoker": 1 if row["smoker"] == 'yes' else 0,
        "region": row["region"],
        "charges": float(row["charges"])
    }

def run(
    input_subscription: str,
    output_table: str,
    window_interval_sec: int = 60,
    beam_args: List[str] = None,
) -> None:
    """Build and run the pipeline."""
    options = PipelineOptions(beam_args, save_main_session=True, streaming=True)

    with beam.Pipeline(options=options) as pipeline:
        messages = (
            pipeline
            | "Read from Pub/Sub"
            >> beam.io.ReadFromPubSub(
                subscription=input_subscription
            ).with_output_types(bytes)
            | "UTF-8 bytes to string" >> beam.Map(lambda msg: msg.decode("utf-8"))
            | "Parse JSON messages" >> beam.Map(parse_json_message)
        )

        # Output the results into BigQuery table.
        _ = messages | "Write to Big Query" >> beam.io.WriteToBigQuery(
            output_table, schema=SCHEMA
        )


if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output_table",
        help="Output BigQuery table for results specified as: "
        "PROJECT:DATASET.TABLE or DATASET.TABLE.",
    )
    parser.add_argument(
        "--input_subscription",
        help="Input PubSub subscription of the form "
        '"projects/<PROJECT>/subscriptions/<SUBSCRIPTION>."',
    )
    parser.add_argument(
        "--window_interval_sec",
        default=60,
        type=int,
        help="Window interval in seconds for grouping incoming messages.",
    )
    args, beam_args = parser.parse_known_args()

    run(
        input_subscription=args.input_subscription,
        output_table=args.output_table,
        window_interval_sec=args.window_interval_sec,
        beam_args=beam_args,
    )
