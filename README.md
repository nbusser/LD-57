# LD-57 - Deep Pockets

This is the code for the Ludum Dare 57 game jam.

Theme: Depths

## Git hooks

Please install the git hooks by running:

```sh
git config core.hooksPath "./hooks"
```

It requires you to install gdtoolkit. Here is a quick start:

```sh
# if uv is available
uv sync
# and activate the venv
source .venv/bin/activate

# or if using a basic venv
python3 -m venv .env
pip3 install -r requirements.txt
```

You can then run the `gdformat` and `gdlint` utils.

To format the whole project:

```sh
gdformat .
```

Check the [gdlint doc](https://github.com/Scony/godot-gdscript-toolkit/wiki/3.-Linter) for more details.
