# pylsp-rope.el
This package provides emacs commands for the [pylsp-rope](https://github.com/python-rope/pylsp-rope) plugin for the [Python LSP Server](https://github.com/python-lsp/python-lsp-server).

## Installation

- With `use-package` and `straight.el`:
``` emacs-lisp
(use-package pylsp-rope
  :straight (fatebook :repo "sonofhypnos/pylsp-rope.el" :host github
                      :files ("pylsp-rope.el"))
  :commands fatebook-create-question)
```


- [Doom Emacs](https://github.com/hlissner/doom-emacs):

``` emacs-lisp
(package! pylsp-rope
  :recipe (:host github
           :repo "sonofhypnos/pylsp-rope.el"))
```
