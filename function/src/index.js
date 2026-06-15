class SampleEvent {
  constructor(event) {
    this._event = event || {};
  }

  getKey() {
    return this._event.key || "";
  }
}

exports.initializer = function (context, callback) {
  const logger = context.getLogger();
  logger.info("initializing :", context.getFunctionName());

  callback(null, "");
};

exports.handler = async (event, context) => {
  const logger = context.getLogger();

  logger.info("Function name:", context.getFunctionName());

  const sampleEvent = new SampleEvent(event);

  logger.info("Key value from event:", sampleEvent.getKey());

  const output = {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
    },
    isBase64Encoded: false,
    body: JSON.stringify(event),
  };

  await new Promise((resolve) => {
    setTimeout(resolve, 2000);
  });

  return output;
};
