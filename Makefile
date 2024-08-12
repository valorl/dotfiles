default: brew stow

brew:
	/opt/homebrew/bin/brew bundle

stow:
	/opt/homebrew/bin/stow --dir home --target ~ .
unstow:
	/opt/homebrew/bin/stow --dir home --target ~ -D .
