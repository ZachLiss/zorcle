let MascotGame = {
	init(socket, element) {
		if (!element) { return }

		const mascotGameId = 1;
		socket.connect();
		this.onReady(mascotGameId, socket);
	},

	onReady(mascotGameId, socket) {
		const mascotGameChannel = socket.channel('mascot_game:' + mascotGameId);
		const startButton = document.querySelector('#start-game-button');
		const endButton = document.querySelector('#end-game-button');

		mascotGameChannel.on('ping', ({count}) => {
			console.log("PING", count)
			mascotGameChannel.push('pong', { count }).receive("error", e => console.log(e))
		});

		mascotGameChannel.on('start_game', () => {
			console.log('starting the game')

			startButton.disabled = true;
			endButton.disabled = false;
		})

		mascotGameChannel.on('end_game', () => {
			console.log('ending the game')

			startButton.disabled = false;
			endButton.disabled = true;
		})

		startButton.addEventListener("click", e => {
			// start the game
			mascotGameChannel.push('start_game');
		});

		endButton.addEventListener("click", e => {
			// end the game
			mascotGameChannel.push('end_game');
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
