# Lunar Workspace - Noctalia Plugin

A customizable workspace widget plugin for Noctalia. Replace your default workspace numbers or dots with custom emojis, static images, or animated GIFs to give your desktop a highly personalized touch.

## Features

- **Rich Media Support:** Set your workspace indicators to use emojis, local images (PNG/JPG), or animated GIFs.
- **Integrated UI:** Built-in `ImagePickerPanel.qml` and `Settings.qml` means you can configure everything directly through Noctalia's graphical interface without editing config files manually.
- **Native Rendering:** Written entirely in QML to integrate seamlessly and efficiently with Noctalia's bar.

## Preview

<video src="https://github.com/user-attachments/assets/2f894449-57b4-43ce-8ed9-1900412e8c2f" width="400" controls></video>

## Installation

To add this plugin to your Noctalia setup, follow these steps:

1. Open your terminal and navigate to your Noctalia plugins directory. This is typically located inside your user config folder:
   ```bash
   cd ~/.config/noctalia/plugins/
   ```
   *(If the `plugins` directory doesn't exist yet, you can create it with `mkdir -p ~/.config/noctalia/plugins/`)*

2. Clone this repository directly into the folder:
   ```bash
   git clone https://github.com/Niko-Cloud/Lunar-Workspace-Noctalia-Plugin.git LunarWorkspace
   ```

3. Reload or restart Noctalia. It will read the `manifest.json` file and register the plugin automatically.

## Usage & Configuration

1. While Noctalia is running, enter its edit mode or open your bar configuration menu.
2. Add the **Lunar Workspace** widget (which loads `BarWidget.qml`) to your preferred spot on the bar.
3. Open the widget's settings. This will launch the included `Settings.qml` interface.
4. Use the image picker panel to browse your system and assign your desired emojis, images, or GIFs to your workspaces.
5. Apply your changes. Your selections are automatically saved to the `settings.json` file inside the plugin folder so they persist across reboots.

## License

This project is licensed under the [MIT License](LICENSE).
