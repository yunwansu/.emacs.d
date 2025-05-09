;;; package --- Summary
;;; Commentary:
(setq package-enable-at-startup nil)
(setq use-package-always-ensure t)

(require 'package)

;;; Code:
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(prodigy company-mode company anzu doom-modeline org-bullets whitespace-cleanup-mode flycheck-pos-tip flycheck cider rainbow-delimiters smartparens clojure-mode ace-window all-the-icons doom-themes magit markdown-mode orderless vertico use-package consult))
 '(session-use-package t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; hide scroll-bar
(scroll-bar-mode -1)
;; hide tool-bar
(tool-bar-mode -1)
;; Long line truncate
(set-default 'truncate-lines t)

(display-time-mode t)

(setq gc-cons-threshold (* 100 1024 1024))  ;; 100MB

(when (fboundp 'global-so-long-mode)
  (global-so-long-mode 1))

(setq use-package-always-ensure t)


(use-package consult
  :ensure t
  :bind (
	 ("C-c M-x" . consult-mode-command)
	 ("C-x b" . consult-buffer))

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode))

(use-package vertico
  :ensure t
  :defer t
  :init
  (vertico-mode)

  ;; Different scroll margin
  (setq vertico-scroll-margin 0)

  ;; Show more condidates
  (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  (setq vertico-cycle t)
  )

;; vertico configuration
;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; vertico configuration
;; A few more useful configurations...
(use-package emacs
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
		  (replace-regexp-in-string
		   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
		   crm-separator)
		  (car args))
	  (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
	'(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

   ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure t
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Configure directory extension.
(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
	      ("RET" . vertico-directory-enter)
	      ("DEL" . vertico-directory-delete-char)
	      ("M-DEL" . vertico-directory-delete-word))
  ;;Tidy sadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
	doom-themes-enable-italic t) ; if num, italic is universally disabled
  (load-theme 'doom-one t)
  (global-display-line-numbers-mode)
  (global-hl-line-mode)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package anzu
  :ensure t
  :hook
  (after-init . global-anzu-mode))

;; need install fonts
;; M-x all-the-icons-install-fonts
(use-package all-the-icons
  :if (display-graphic-p)
  :config
  (unless (member "all-the-icons" (font-family-list))
    (all-the-icons-install-fonts t)))

(use-package ace-window
  :ensure t
  :defer t
  :bind ("C-x o" . 'ace-window))

;; copy Steve Purcell's code  https://github.com/purcell/emacs.d/blob/master/lisp/init-gui-frames.el#L42
(defun sanityinc/adjust-opacity (frame incr)
  "Adjust the background opacity of FRAME by increment INCR."
  (unless (display-graphic-p frame)
    (error "Cannot adjust opacity of this frame"))
  (let* ((oldalpha (or (frame-parameter frame 'alpha) 100))
         ;; The 'alpha frame param became a pair at some point in
         ;; emacs 24.x, e.g. (100 100)
         (oldalpha (if (listp oldalpha) (car oldalpha) oldalpha))
         (newalpha (+ incr oldalpha)))
    (when (and (<= frame-alpha-lower-limit newalpha) (>= 100 newalpha))
      (modify-frame-parameters frame (list (cons 'alpha newalpha))))))

(keymap-global-set "C-*" (lambda () (interactive) (sanityinc/adjust-opacity nil -2)))
(keymap-global-set "C-(" (lambda () (interactive) (sanityinc/adjust-opacity nil 2)))
(keymap-global-set "C-&" (lambda () (interactive) (modify-frame-parameters nil `((alpha . 100)))))


(use-package rainbow-delimiters
  :ensure t)

(use-package smartparens
  :ensure t)

(use-package clojure-mode
  :ensure t
  :defer t
  :hook
  ((clojure-mode . subword-mode)
   (clojure-mode . smartparens-mode)
   (clojure-mode . rainbow-delimiters-mode)))

(use-package cider
  :ensure t
  :defer t)

(use-package flycheck
  :ensure t
  :hook
  (after-init . global-flycheck-mode))

(use-package flycheck-pos-tip
  :ensure t
  :after flycheck)

(use-package yaml-mode
  :defer t
  :ensure t)

(use-package magit
  :defer t
  :ensure t)

(use-package whitespace-cleanup-mode
  :ensure t
  :hook
  (after-init 'global-whitespace-cleanup-mode))

(use-package marginalia
  :after vertico
  :ensure t
  :init
  (marginalia-mode))

(use-package org-bullets
  :ensure t)

(use-package org
  :init
  (setq org-agenda-files '("~/my_work/gtd/"))
  :hook
  ((org-mode . org-indent-mode)
   (org-mode . org-bullets-mode)))

(use-package company
  :ensure t
  :defer t
  :config
  (setq company-tooltip-align-annotations t
	company-tooltip-flip-when-above t
	company-dabbrev-downcase nil)
  :hook
  (after-init . global-company-mode))

(use-package prodigy
  :ensure t
  :defer t)

(use-package go-mode
  :ensure t
  :defer t)


(use-package web-mode
  :ensure t
  :mode
  (("\\.phtml\\'" . web-mode)
   ("\\.php\\'" . web-mode)
   ("\\.tpl\\'" . web-mode)
   ("\\.[agj]sp\\'" . web-mode)
   ("\\.as[cp]x\\'" . web-mode)
   ("\\.erb\\'" . web-mode)
   ("\\.mustache\\'" . web-mode)
   ("\\.djhtml\\'" . web-mode)
   ("\\.ftl\\'" . web-mode))
;;; init.el ends here
