export function setup(instance, domNode) {
  var state = { intervalId: null, tickCount: 0 };

  instance.on("startTimer", function ({ intervalMs, tickCount }) {
    if (state.intervalId) {
      clearInterval(state.intervalId);
    }
    state.tickCount = tickCount;
    state.intervalId = setInterval(function () {
      state.tickCount++;
      instance.send("onTick", state.tickCount);
    }, intervalMs);
  });

  instance.on("stopTimer", function () {
    if (state.intervalId) {
      clearInterval(state.intervalId);
      state.intervalId = null;
    }
  });
}

export function teardown(instance, domNode, state) {
  if (state && state.intervalId) {
    clearInterval(state.intervalId);
  }
}
