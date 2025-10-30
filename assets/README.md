# Assets Directory

This directory contains all the static assets for the Posture Health Assistant app.

## Directory Structure

```
assets/
├── images/          # PNG/JPG images for the app
├── animations/      # Lottie animation files
├── icons/          # SVG and PNG icons
├── models/         # TensorFlow Lite models (if needed)
└── fonts/          # Custom fonts (Poppins)
```

## Adding Assets

### Images
Place image files in the `images/` directory. Supported formats:
- PNG (recommended for icons and graphics)
- JPG/JPEG (for photos)
- WebP (for optimized images)

### Animations
Place Lottie animation JSON files in the `animations/` directory.

### Icons
Place icon files in the `icons/` directory. Use SVG for scalable icons.

### Fonts
The app uses the Poppins font family. Add the following font files to the `fonts/` directory:
- Poppins-Regular.ttf
- Poppins-Medium.ttf
- Poppins-SemiBold.ttf
- Poppins-Bold.ttf

You can download Poppins from [Google Fonts](https://fonts.google.com/specimen/Poppins).

### Models
If using custom TensorFlow Lite models for pose detection, place them in the `models/` directory.

## Note
Remember to update `pubspec.yaml` when adding new assets to ensure they're included in the app bundle.
