let MascotGame = {
	init(socket, element) {
		if (!element) { return }

		const mascotGameId = 1;
		this.onReady(mascotGameId, socket);
	},

	onReady(mascotGameId, socket) {
		const mascotGameChannel = socket.channel('mascot_games:' + mascotGameId);
		console.log('trying to join')

		// TODO join the game channel
		mascotGameChannel.join()
			.receive('ok', resp => console.log('joined the mascot game channel', resp))
			.receive('error', reason => console.log('join failed', reason))
	}
}

export default MascotGame;
