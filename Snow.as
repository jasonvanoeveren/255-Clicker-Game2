package {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;


	public class Snow extends MovieClip {
		/** Speed of snowflakes. */
		public var speed: Number;

		/** If this is true, the object is queued up to be destroyed!! */
		public var isDead: Boolean = false;

		/** Tracks unscored points for the game. */
		public var unscoredPoints: int = 0;

		/** Handles the color for the snow. 
		 * Sets the designated RBG values to color variables.
		 */
		private var colorTransform = new ColorTransform();
		private var purple: uint = 0x800080;
		private var yellow: uint = 0xFFFF00;
		private var green: uint = 0x00FF00;

		/** Instantiates sound for each of the snowflakes. */
		private var yellowSound: YellowSound = new YellowSound();
		private var greenSound: GreenSound = new GreenSound();
		private var purpleSound: PurpleSound = new PurpleSound();

		/** The Snow object.
		 * Sets the speed and scale of each snowflake randomly.
		 * Also assigns a color to the snow based on their size.
		 */
		public function Snow() {
			x = Math.random() * 550;
			y = -50;
			speed = Math.random() * 3 + 2; // 2 to 5
			scaleX = Math.random() * .2 + .1; // .1 to .3
			scaleY = scaleX;
			addEventListener(MouseEvent.MOUSE_DOWN, handleClick);

			if (scaleX >= .25) {
				colorTransform.color = yellow;
				transform.colorTransform = colorTransform;
			} else if (scaleX >= .15 && scaleX < .25) {
				colorTransform.color = green;
				transform.colorTransform = colorTransform;
			} else if (scaleX < .15) {
				colorTransform.color = purple;
				transform.colorTransform = colorTransform;
			}
		}

		/** The update design pattern. */
		public function update(): void {
			// Snowflakes constantly fall.  If they reach past the end of the screen, they are destroyed.
			y += speed;
			if (y > 400) {
				isDead = true;
			}
		}

		/** 
		 * This checks for when the user clicks on a snowflake.
		 * @param e The event that triggers the MouseEvent.
		 */
		private function handleClick(e: MouseEvent): void {
			isDead = true;

			// Player scores a different number of points based on what color snowflake they click.
			// A different sound plays as well for each color.
			if (transform.colorTransform.color == yellow) {
				unscoredPoints = 100;
				yellowSound.play();
			} else if (transform.colorTransform.color == green) {
				unscoredPoints = 300;
				greenSound.play();
			} else if (transform.colorTransform.color == purple) {
				unscoredPoints = 500;
				purpleSound.play();
			}
		}
		/**
		 * This function's job is to prepare the object for removal.
		 * In this case, we need to remove any event-listeners on this object.
		 */
		public function dispose(): void {
			removeEventListener(MouseEvent.MOUSE_DOWN, handleClick);
		}
	}

}