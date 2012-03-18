var err = initInstall("Icelandic Dictionary", "is@dictionaries.addons.mozilla.org", "TODAYPLACEHOLDER");
if (err != SUCCESS)
    cancelInstall();

var fProgram = getFolder("Program");
err = addDirectory("", "is@dictionaries.addons.mozilla.org",
           "dictionaries", fProgram, "dictionaries", true);
if (err != SUCCESS)
    cancelInstall();

performInstall();
