// a simple game where you press a button to a certain time

package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"

BUTTON_POS :: rl.Vector2{150, 250}
BUTTON_RADIUS :: 50

Phase :: enum {
	Playing,
	Result,
}

new_target :: proc() -> f64 {
	return f64(rand.int_range(200, 1001)) / 100.0
}

format_time :: proc(seconds: f64) -> cstring {
	s := seconds
	if s < 0 {
		s = 0
	}
	if s > 99.99 {
		s = 99.99
	}
	total := int(s * 100.0)
	return fmt.ctprintf("{:02d}:{:02d}", total / 100, total % 100)
}

centered_x :: proc(text: cstring, size: i32) -> i32 {
	return (rl.GetScreenWidth() - rl.MeasureText(text, size)) / 2
}

main :: proc() {
	rl.InitWindow(300, 400, "Press the Button")
	rl.SetTargetFPS(60)
	defer rl.CloseWindow()

	phase := Phase.Playing
	target := new_target()
	round_start := rl.GetTime()
	press_time: f64

	for !rl.WindowShouldClose() {
		elapsed := rl.GetTime() - round_start

		clicked := rl.IsMouseButtonPressed(.LEFT) &&
			rl.CheckCollisionPointCircle(rl.GetMousePosition(), BUTTON_POS, BUTTON_RADIUS)

		switch phase {
		case .Playing:
			if clicked {
				press_time = elapsed
				phase = .Result
			}
		case .Result:
			if clicked || rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
				target = new_target()
				round_start = rl.GetTime()
				phase = .Playing
			}
		}

		shown := elapsed
		if phase == .Result {
			shown = press_time
		}

		target_str := format_time(target)
		shown_str := format_time(shown)

		rl.BeginDrawing()
		rl.ClearBackground(rl.GRAY)

		rl.DrawText("TARGET", centered_x("TARGET", 20), 15, 20, rl.DARKGRAY)
		rl.DrawText(target_str, centered_x(target_str, 50), 38, 50, rl.BLACK)

		rl.DrawText("CLOCK", centered_x("CLOCK", 20), 105, 20, rl.DARKGRAY)
		rl.DrawText(shown_str, centered_x(shown_str, 40), 126, 40, rl.BLACK)

		rl.DrawCircleV(BUTTON_POS, BUTTON_RADIUS, rl.RED)

		switch phase {
		case .Playing:
			rl.DrawText("click at the right moment", centered_x("click at the right moment", 14), 330, 14, rl.DARKGRAY)
		case .Result:
			diff := press_time - target
			off := diff
			if off < 0 {
				off = -off
			}

			verdict: cstring = "TOO LATE"
			verdict_color := rl.ORANGE
			if off <= 0.03 {
				verdict = "PERFECT"
				verdict_color = rl.GREEN
			} else if off <= 0.10 {
				verdict = "GREAT"
				verdict_color = rl.GREEN
			} else if off <= 0.25 {
				verdict = "GOOD"
				verdict_color = rl.DARKGREEN
			} else if diff < 0 {
				verdict = "TOO EARLY"
			}

			diff_str := fmt.ctprintf("{:+.2f}s", diff)

			rl.DrawText(diff_str, centered_x(diff_str, 30), 312, 30, rl.BLACK)
			rl.DrawText(verdict, centered_x(verdict, 22), 348, 22, verdict_color)
			rl.DrawText("space: next round", centered_x("space: next round", 14), 376, 14, rl.DARKGRAY)
		}

		rl.EndDrawing()
	}
}
