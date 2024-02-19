let MascotGame = {
	init(socket, element) {
		if (!element) { return }

		// currently hard coding this id
		// ideas around making this more flexible
		const mascotGameId = 1;
		socket.connect();
		this.onReady(mascotGameId, socket);
	},

	onReady(mascotGameId, socket) {
		const mascotGameChannel = socket.channel('mascot_game:' + mascotGameId);
		const startButton = document.querySelector('#start-game-button');
		const endButton = document.querySelector('#end-game-button');
		const gameForm = document.querySelector('#game-form');
		const schoolValue = document.querySelector('#school-value');
		const submitButton = document.querySelector('#submit-button');
		const mascotInput = document.querySelector('#mascot-input');
		const scoreValue = document.querySelector('#score-value');
		const feedback = document.querySelector('#feedback');

		startButton.addEventListener("click", e => {
			// start the game
			mascotGameChannel.push('start_game');
		});

		endButton.addEventListener("click", e => {
			// end the game
			mascotGameChannel.push('end_game');
		});

		submitButton.addEventListener("click", e => {
			// submit the game
			mascotGameChannel.push('submit_answer', { mascot: mascotInput.value })
				.receive("ok", () => {
					feedback.innerHTML = 'Correct!';
					mascotInput.value = '';
					setTimeout(() => feedback.innerHTML = '', 2000)
				})
				.receive("incorrect", () => {
					feedback.innerHTML = 'NOPE YOU IDIOT';
					setTimeout(() => feedback.innerHTML = '', 2000)
				});
		});

		mascotGameChannel.on('ping', ({count}) => {
			console.log("PING", count)
			mascotGameChannel.push('pong', { count }).receive("error", e => console.log(e))
		});

		mascotGameChannel.on('start_game', () => {
			console.log('starting the game')

			startButton.disabled = true;
			endButton.disabled = false;
			gameForm.style.display = "block";
		});

		mascotGameChannel.on('end_game', () => {
			console.log('ending the game')

			startButton.disabled = false;
			endButton.disabled = true;
			gameForm.style.display = "none";
		});

		mascotGameChannel.on('new_question', ({school}) => {
			console.log('SCHOOL: ' + school);
			schoolValue.innerHTML = school;
		});

		mascotGameChannel.on('correct_answer', ({score}) => {
			console.log('SCORE: ' + score)
			scoreValue.innerHTML = score;
		})
		// TODO join the game channel
		// join existing game or start a new one
		mascotGameChannel.join()
			.receive('ok', resp => {
				console.log('joined the mascot game channel', resp)
			})
			.receive('error', reason => console.log('join failed', reason))
	}
}

export default MascotGame;