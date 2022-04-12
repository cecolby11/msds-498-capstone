exports.handler = async (req, res) => {
  try {
    console.log('function invoked by HTTP!');
    res.send('hello world');
  } catch (err) {
    console.error('AN ERROR OCCURRED');
    console.error(err);
    res.send(err);
  }
};
