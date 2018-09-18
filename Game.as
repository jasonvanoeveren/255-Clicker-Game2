package {

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.utils.setTimeout;

	/**
	 * This is the controller class for the entire Game.
	 */
	public class Game extends MovieClip {

		/** Boolean flag to check if game has started. */
		var startGame: Boolean = false;

		/** Boolean flag to check if game over sound has already played. */
		var gameOverSoundPlayed: Boolean = false;

		/** This array should only hold Snow objects. */
		var snowflakes: Array = new Array();

		/** The number frames to wait before spawning the next Snow object. */
		var delaySpawn: int = 0;

		/** Tracks the score of the game. */
		var score: int = 0;

		/** Tracks number of misses. */
		var missCount: int = 0;

		/** Tracks score needed to speed up snowflakes. */
		var targetScore: int = 1000;

		/** Sets the color value for the stage. */
		private var colorTransform = new ColorTransform();
		private var red: uint = 0xff0000;
		private var skyBlue: uint = 0x0099ff;

		/** Instantiates Instructions Screen. */
		private var instructions: Instructions = new Instructions();

		/** Instantiates Start Button. */
		private var startBtn: StartGame = new StartGame();

		/** Instantiates Game Over screen. */
		private var gameOver: GameOver = new GameOver();

		/** Instantiates restart screen. */
		private var restart: Restart = new Restart();

		/** Instantiate Music and Sound. */
		private var bgMusic: BGMusic = new BGMusic();
		private var gameOverSound: GameOverSound = new GameOverSound();
		
		/** Increases speed of snowflakes when difficulty increases. */
		private var difficultySpeed: int = 0;
		
		/** Checks for when the difficulty increases. */
		private var increaseDifficulty: Boolean = false;

		/**
		 * This is where we setup the game.
		 */
		public function Game() {

			//Play background music.
			bgMusic.play();

			// Game Loop event added.
			addEventListener(Event.ENTER_FRAME, gameLoop);

			// Click event added.
			addEventListener(MouseEvent.MOUSE_DOWN, handleClick);

			// Add all necessary children.
			addChild(instructions);
			addChild(startBtn);
			addChild(gameOver);
			addChild(restart);

			// Add click event for start button.
			startBtn.addEventListener(MouseEvent.CLICK, startClick);

			// Set instructions and start button coordinates.
			instructions.x = 260;
			instructions.y = 200;
			startBtn.x = 270;
			startBtn.y = 350;

			// Set visibility for unneeded children.
			gameOver.visible = false;
			restart.visible = false;
			scoreboard.visible = false;
			misses.visible = false;

		} // ends function Game
		/**
		 * This event-handler is called every time a new frame is drawn.
		 * It's our game loop!
		 * @param e The Event that triggered this event-handler.
		 */
		private function gameLoop(e: Event): void {
			
			// If the start button is hit, begin spawning and updating snow.
			if (startGame == true) {

				spawnSnow();

				updateSnow();

				instructions.visible = false;
				startBtn.visible = false;
				scoreboard.visible = true;
				misses.visible = true;
			}

			//Update Scoreboard.
			scoreboard.text = "SCORE: " + score;

			//Update Miss Count.
			misses.text = "MISSES: " + missCount;

			//Check for game over.
			gameOverCheck();

		} // function gameLoop

		/**
		 * Decrements the countdown timer, when it hits 0, it spawns a snowflake.
		 */
		private function spawnSnow() {
			// spawn snow:
			delaySpawn--;
			if (delaySpawn <= 0) {
				var s: Snow = new Snow();
				addChild(s);
				s.speed += difficultySpeed;
				snowflakes.push(s);
				delaySpawn = (int)(Math.random() * 10 + 10);
			}

		} // ends spawnSnow

		private function updateSnow() {
			// update everything:
			for (var i = snowflakes.length - 1; i >= 0; i--) {
				snowflakes[i].update();

				if (snowflakes[i].unscoredPoints > 0) {
					score += snowflakes[i].unscoredPoints;
					snowflakes[i].unscoredPoints = 0;
				}

				//Increases speed of snow every 1000 points.
				increaseSpeedCheck();
				
				// If difficulty increases, increase speed.
				if (increaseDifficulty == true){
					difficultySpeed += 1;
					snowflakes[i].speed += difficultySpeed;
					targetScore += 1000;
					increaseDifficulty = false;
				}

				if (snowflakes[i].isDead) {
					// remove it!!

					// 1. remove any event-listeners on the object
					snowflakes[i].dispose();

					// 2. remove the object from the scene-graph
					removeChild(snowflakes[i]);

					// 3. nullify any variables pointing to it
					// if the variable is an array,
					// remove the object from the array
					snowflakes.splice(i, 1);
				}
			} // for loop updating snow

		} // ends updateSnow

		/** Checks for game over. */
		private function gameOverCheck() {
			// If number of misses is equal to three, display game over screen.
			if (missCount == 3) {

				if (gameOverSoundPlayed == false) {

					gameOverSound.play();
					gameOverSoundPlayed = true;

				}

				for (var i = snowflakes.length - 1; i >= 0; i--) {
					snowflakes[i].dispose();
					removeChild(snowflakes[i]);
					snowflakes.splice(i, 1);
				}

				gameOver.visible = true;
				restart.visible = true;

				gameOver.x = 275;
				gameOver.y = 150;

				restart.x = 275;
				restart.y = 250;
				restart.addEventListener(MouseEvent.CLICK, restartClick);

			}
		} // ends gameOverCheck

		/** Sets boolean flag to true when it's time for the difficulty to increase. */
		private function increaseSpeedCheck() {

			for (var i = snowflakes.length - 1; i >= 0; i--) {

				if (score >= targetScore) {
					increaseDifficulty = true;
				}

			}
		} // ends increaseSpeedCheck

		/**
		 * This checks for any misses when the user accidentally clicks the stage.
		 * @param e The event that triggers the MouseEvent.
		 */
		private function handleClick(e: MouseEvent): void {

			// If the user misses a snowflake, make the screen flash red.
			if (e.target == background && missCount < 3) {
				missCount++;
				colorTransform.color = red;
				background.transform.colorTransform = colorTransform;

				setTimeout(function () {
					colorTransform.color = skyBlue;
					background.transform.colorTransform = colorTransform;
				}, 100);

			}
		} // ends handleClick

		/**
		 * This is the click event for the start game button.
		 * It starts the game.
		 * @param e The event that triggers the MouseEvent.
		 */
		private function startClick(e: MouseEvent): void {

			startGame = true;

		} // ends startClick

		/**
		 * This is the click event for the restart button.
		 * It restarts the game.
		 * @param e The event that triggers the MouseEvent.
		 */
		private function restartClick(e: MouseEvent): void {

			missCount = 0;
			score = 0;
			difficultySpeed = 0;
			increaseDifficulty = false;

			gameOver.visible = false;
			restart.visible = false;
			restart.removeEventListener(MouseEvent.CLICK, restartClick);

			gameOverSoundPlayed = false;

		} // ends restartClick
	} // class Game
} // package