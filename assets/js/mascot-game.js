let MascotGame = {
	init(socket, element) {
		if (!element) { return }

		const mascotGameId = 1;
		socket.connect();
		this.onReady(mascotGameId, socket);

		element.querySelector("#start-game-button").addEventListener("click", e => {
			// start the game
			console.log('imma try to start the game')
		});

	},

	onReady(mascotGameId, socket) {
		const mascotGameChannel = socket.channel('mascot_game:' + mascotGameId);

		mascotGameChannel.on('ping', ({count}) => {
			console.log("PING", count)
			mascotGameChannel.push('pong', { count }).receive("error", e => console.log(e))
		});
		console.log('trying to join')

		// TODO join the game channel
		mascotGameChannel.join()
			.receive('ok', resp => {
				console.log('joined the mascot game channel', resp)
			})
			.receive('error', reason => console.log('join failed', reason))
	}
}

export default MascotGame;
