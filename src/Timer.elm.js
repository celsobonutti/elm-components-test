export function setup(instance, domNode) {
  var state = { intervalId: null, tickCount: 0 };

  instance.on("startTimer", function (intervalMs) {
    if (state.intervalId) {
      clearInterval(state.intervalId);
    }
    state.tickCount = 0;
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

  return state;
}

export function teardown(instance, domNode, state) {
  if (state && state.intervalId) {
    clearInterval(state.intervalId);
  }
}
