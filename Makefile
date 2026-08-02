default: brew stow

brew:
ifeq ($(shell uname -s), Darwin)
	brew bundle
endif

stow:
	mkdir -p ~/.config
	mkdir -p ~/.local
	stow --dir home --target ~ .
unstow:
	stow --dir home --target ~ -D .
