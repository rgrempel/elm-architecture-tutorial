// This is copied and renamed from
//
// https://github.com/evancz/elm-effects/blob/master/src/Native/Effects.js

Elm.Native.Tick = {};
Elm.Native.Tick.make = function(localRuntime) {

	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.Tick = localRuntime.Native.Tick || {};
	if (localRuntime.Native.Tick.values)
	{
		return localRuntime.Native.Tick.values;
	}

	var Task = Elm.Native.Task.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);


	function raf(timeToTask)
	{
		return Task.asyncFunction(function(callback) {
			requestAnimationFrame(function(time) {
				Task.perform(timeToTask(time));
			});
			callback(Task.succeed(Utils.Tuple0));
		});
	}

	return localRuntime.Native.Tick.values = {
		requestAnimationFrame: raf
	};

};
