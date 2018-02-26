// For more information on customizing Oni,
// check out our wiki page:
// https://github.com/onivim/oni/wiki/Configuration

const activate = oni => {
    console.log("config activated")

    // Input
    //
    // Add input bindings here:
    //
    oni.input.bind("<c-enter>", () => console.log("Control+Enter was pressed"))

    //
    // Or remove the default bindings here by uncommenting the below line:
    //
    oni.input.unbind("<c-p>")
    oni.commands.executeCommand("sidebar.toggle")
}

const deactivate = () => {
    console.log("config deactivated")
}

module.exports = {
    activate,
    deactivate,
    //add custom config here, such as

    "ui.colorscheme": "neg",
    "oni.useDefaultConfig": false, 
    "oni.hideMenu": true,
    "oni.useExternalPopupMenu": true,
    "oni.loadInitVim": true,
    "editor.fontSize": "19pt",
    "editor.fontFamily": "Iosevka Term Medium",
    "editor.completions.enabled": true,
    "editor.backgroundImageUrl": "/home/neg/pic/wl/HeuanqL.jpg",
    "editor.backgroundOpacity": 0.9,
    "commandline.mode": true,

    // UI customizations
    "ui.animations.enabled": true,
    "ui.fontSmoothing": "auto",
}
