default: brew stow

brew:
	/opt/homebrew/bin/brew bundle

# Real dirs first: stow links a missing dir as a whole ("folding"), and then
# everything later written there lands in this repo. ~/.config/herdr-app is
# deliberately left out: it is meant to fold (see its .gitignore).
stow:
	mkdir -p ~/.config ~/.local/bin ~/forge/herdr/.claude ~/forge/session-spawner
	/opt/homebrew/bin/stow --dir home --target ~ .
unstow:
	/opt/homebrew/bin/stow --dir home --target ~ -D .
