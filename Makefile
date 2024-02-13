default: brew stow

brew:
	brew bundle

stow:
	stow --dir home --target ~ .
unstow:
	stow --dir home --target ~ -D .
