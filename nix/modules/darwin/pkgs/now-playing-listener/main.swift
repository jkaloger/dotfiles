import Foundation

let center = DistributedNotificationCenter.default()

let notifications: [(String, String)] = [
    ("com.spotify.client.PlaybackStateChanged", "Spotify"),
    ("com.apple.Music.playerInfo", "Music"),
]

for (name, _) in notifications {
    center.addObserver(
        forName: NSNotification.Name(name),
        object: nil,
        queue: nil
    ) { _ in
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.arguments = ["sketchybar", "--trigger", "now_playing_change"]
        try? task.run()
        task.waitUntilExit()
    }
}

RunLoop.main.run()
