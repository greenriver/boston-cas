The icon font is generated at fontello.

To recreate the icon font and add to it:
1. At https://fontello.com upload the existing fontello-config.json from this directory
2. Add new characters/images
3. Ensure the font is named "icons"
4. Click 'Download webfont' button (zip file)
5. From the zipped file, copy the font files (eot, svg, ttf, woff, woff2) and fontello-config.json (named config.json in the download) to the /app/assets/fonts directory, replacing the files already there
6. From the zip file's css/icon-codes.css, copy all of the css declarations
7. In the stylesheet (/app/assets/stylesheets/settings/_icons.scss), update the icon map with the new version
8. Make sure you update app/views/style_guides/icon_font.haml with any icons you add

To view all of the icons currently in use in the app, in development or on staging, view /style_guide/icon_font
