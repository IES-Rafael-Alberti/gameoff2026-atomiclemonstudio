# ColorShift — Technical Scene & Dialogue Script

This document outlines the **3 narrative cutscenes** for implementation in Godot 4.7, detailing triggers, backgrounds, character entrances/exits, portrait/sprite emotions, and dialogue lines.

## Implementation Conventions

* **Suggested Portrait / Sprite Emotions:**
  * `normal`: Neutral, attentive, or calm expression.
  * `angry`: Furrowed brow, tension, or combative determination.
  * `sad`: Downcast gaze, dismay, or defeated shock.
* **Action Notation:** `[ACTION]` indicates visual cues, camera movements, character entrances/exits, or screen filter effects.

---

## Scene 1: The Color Heist & The Chromoscope

* **Trigger:** Game start / Level 1 Intro.
* **Background:** Outer ruins of **ChromaVale** at dawn. At the start of the scene, the sky and stonework drain of color until everything settles into **grayscale**. On the ground near center-left lies the **Chromoscope**, glinting faintly with a single lens attached.
* **Starting Characters on Screen:**
  * **Larry:** Standing on the left, looking toward the background/right.
  * **Béchamel the Sixth:** Perched on an elevated ledge on the right, surrounded by a swirling aura of stolen colors that fades as he absorbs them.

### Dialogue Sequence

1. **\[ACTION\]** *The last traces of color drain from the environment into full grayscale. Béchamel the Sixth chuckles from the right ledge.*
2. **Béchamel the Sixth** *(Emotion: `normal` — smug and theatrical)*:
   > "How wonderfully quiet ChromaVale becomes once I pocket all the color! A gray world is terribly dull... and entirely mine."
3. **Larry** *(Emotion: `sad` — looking down at the faded ground)*:
   > "He took all the light from the realm... Everything feels cold and still."
4. **\[ACTION\]** *Béchamel leaps to the right and vanishes off-screen, blending into the gray background.*
   * **Character Exit:** **Béchamel the Sixth exits** off the right edge.
5. **\[ACTION\]** *Larry steps forward, picks up the visor from the ground, and puts on the Chromoscope. A quick shimmer sweeps across the right lens.*
6. **Larry** *(Emotion: `normal`)*:
   > "He left this visor behind... It has a wheel fitted with three colored lenses."
7. **\[ACTION\]** *A brief color filter flashes on screen, demonstrating a gray block shifting state.*
8. **Larry** *(Emotion: `angry` — resolute and ready to advance)*:
   > "When I turn the wheel, the world answers back. I won't let him get away with this—I'm bringing every color home."
9. **\[ACTION\]** *Cutscene ends; player control begins in Level 1.*

---

## Scene 2: The Second Wheel of the Chromoscope

* **Trigger:** Start of **Level 4** (or upon interacting with the second lens pedestal).
* **Background:** Interior chamber of an ancient prismatic workshop in grayscale, featuring overlapping circle engravings on the back wall and an illuminated pedestal in the center.
* **Starting Characters on Screen:**
  * **Larry:** Enters from the left, approaching the central pedestal.
  * *(Béchamel the Sixth is not on screen at the start; he enters mid-scene).*

### Dialogue Sequence

1. **\[ACTION\]** *Larry stops before the central pedestal and picks up the left wheel.*
2. **Larry** *(Emotion: `normal`)*:
   > "Another wheel... It's an exact match for the visor."
3. **\[ACTION\]** *Larry snaps the left wheel over the right one. On the visor HUD, both wheels overlap and emit a brief flash of mixed hues (orange, green, and violet).*
4. **Larry** *(Emotion: `normal` — surprised and focused)*:
   > "With both lenses overlapping, the colors blend together... Red, yellow, and blue reveal entirely new shades."
5. **\[ACTION\]** *On an upper ledge to the right, Béchamel the Sixth suddenly appears, dropping his camouflage.*
   * **Character Entrance:** **Béchamel the Sixth enters** on the upper right.
6. **Béchamel the Sixth** *(Emotion: `angry` — startled and irritated)*:
   > "What?! Where did you find that second piece? Those combinations were supposed to stay locked away!"
7. **Larry** *(Emotion: `angry` — firm and confident)*:
   > "I don't have to rely on a single hue anymore. Now I can mix them to open every path you sealed."
8. **Béchamel the Sixth** *(Emotion: `normal` — composes himself, feigning royal indifference)*:
   > "Pah! You're just spinning glass at random! Let's see how far those little mixtures get you higher up."
9. **\[ACTION\]** *Béchamel turns around and retreats toward the background/right.*
   * **Character Exit:** **Béchamel the Sixth exits** to the right.
10. **\[ACTION\]** *Cutscene ends; Level 4 gameplay begins with both wheels unlocked.*

---

## Scene 3: The Final Dispute & The Return of Color

* **Trigger:** Entering the **Final Level** (pre-fight dispute) and immediately upon **completing it** (transitioning into the Credits).
* **Background:** The Prism Dome—a grand chamber with tall, colorless stained-glass windows in grayscale and a central crystalline core where Béchamel holds the stolen spectrum.

### Part 3A — Before the Final Confrontation

* **Starting Characters on Screen:**
  * **Larry:** Enters from the left.
  * **Béchamel the Sixth:** Waiting at center-right beside the color core.

1. **Béchamel the Sixth** *(Emotion: `angry` — impatient)*:
   > "You made it all the way here? How tiresome! I've shifted hues a thousand times, and still you follow, spinning those wheels!"
2. **Larry** *(Emotion: `angry`)*:
   > "You stole the very pulse of ChromaVale. No more hiding—give the colors back."
3. **Béchamel the Sixth** *(Emotion: `angry` — arrogant)*:
   > "Never! As long as I decide what is seen and what vanishes, this kingdom bends to my palette. Let's see your filters survive this!"
4. **Larry** *(Emotion: `normal` — calm and ready)*:
   > "Every color has its place. Let's finish this."
5. **\[ACTION\]** *Béchamel leaps into the center of the arena; the final level/encounter begins.*

### Part 3B — Upon Clearing the Final Level (Transition to Credits)

* **Background:** The same Prism Dome, except as the dialogue progresses, a vibrant wave of color (red, yellow, blue, orange, green, and violet) radiates from the center, permanently restoring **full color** to the environment without needing a filter.
* **Starting Characters on Screen:**
  * **Larry:** Standing on the left.
  * **Béchamel the Sixth:** Sitting defeated on the floor to the right, stripped of his chromatic aura.

1. **\[ACTION\]** *A chromatic shockwave bursts from the core, flooding the entire chamber with its true colors.*
2. **Béchamel the Sixth** *(Emotion: `sad` — defeated and overwhelmed)*:
   > "Impossible...! The colors are slipping away... I can't hold onto them!"
3. **\[ACTION\]** *Béchamel slowly picks himself up and slinks away toward the right edge.*
   * **Character Exit:** **Béchamel the Sixth exits** off the right edge.
4. **Larry** *(Emotion: `normal` — relieved, gazing around the illuminated hall)*:
   > "Everything is back where it belongs... ChromaVale can breathe again."
5. **\[ACTION\]** *The camera pans gently upward toward the vibrant stained-glass windows, the screen fades smoothly, and the **Credits** roll.*