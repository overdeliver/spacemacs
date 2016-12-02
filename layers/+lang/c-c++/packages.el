;;; packages.el --- C/C++ Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq c-c++-packages
  '(
    cc-mode
    disaster
    clang-format
    cmake-ide
    cmake-mode
    company
    (company-c-headers :toggle (configuration-layer/package-usedp 'company))
    company-ycmd
    flycheck
    gdb-mi
    ggtags
    helm-cscope
    helm-gtags
    semantic
    srefactor
    stickyfunc-enhance
    ycmd
    xcscope
    rtags
    ))

(defun c-c++/init-cc-mode ()
  (use-package cc-mode
    :defer t
    :init
    (progn
      (add-to-list 'auto-mode-alist
                   `("\\.h\\'" . ,c-c++-default-mode-for-headers)))
    :config
    (progn
      (require 'compile)
      (c-toggle-auto-newline 1)
      (dolist (mode '(c++-mode c-mode))
        (spacemacs/declare-prefix-for-mode mode "mc" "compile")
        (spacemacs/declare-prefix-for-mode mode "mg" "goto")
        (spacemacs/declare-prefix-for-mode mode "mp" "project/build system")
        (spacemacs/set-leader-keys-for-major-mode mode
          "ga" 'projectile-find-other-file
          "gA" 'projectile-find-other-file-other-window)))))

(defun c-c++/init-disaster ()
  (use-package disaster
    :defer t
    :commands (disaster)
    :init
    (progn
      (spacemacs/set-leader-keys-for-major-mode 'c-mode
        "D" 'disaster)
      (spacemacs/set-leader-keys-for-major-mode 'c++-mode
        "D" 'disaster))))

(defun c-c++/init-clang-format ()
  (use-package clang-format
    :if c-c++-enable-clang-support))

(defun c-c++/init-cmake-ide ()
  (use-package cmake-ide)
    :config
    (progn
      (cmake-ide-setup)
      (dolist (mode '(c++-mode c-mode))
        (spacemacs/set-leader-keys-for-major-mode mode
          "cc" 'cmake-ide-compile
          "pc" 'cmake-ide-run-cmake
          "pC" 'cmake-ide-maybe-run-cmake
          "pd" 'cmake-ide-delete-file))))

(defun c-c++/init-cmake-mode ()
  (use-package cmake-mode
    :mode (("CMakeLists\\.txt\\'" . cmake-mode) ("\\.cmake\\'" . cmake-mode))
    :init (push 'company-cmake company-backends-cmake-mode)))

(defun c-c++/post-init-company ()
  (spacemacs|add-company-hook c-mode-common)
  (spacemacs|add-company-hook cmake-mode)

  (unless c-c++-enable-clang-support
    (when c-c++-enable-rtags-support
      (push 'company-rtags company-backends-c-mode-common)))

  (when c-c++-enable-clang-support
    (push 'company-clang company-backends-c-mode-common)

    (defun company-mode/more-than-prefix-guesser ()
      (c-c++/load-clang-args)
      (company-clang-guess-prefix))

    (setq company-clang-prefix-guesser 'company-mode/more-than-prefix-guesser)
    (spacemacs/add-to-hooks 'c-c++/load-clang-args '(c-mode-hook c++-mode-hook))))

(defun c-c++/init-company-c-headers ()
  (use-package company-c-headers
    :defer t
    :init (push 'company-c-headers company-backends-c-mode-common)))

(defun c-c++/init-rtags ()
  (use-package rtags
    :if c-c++-enable-rtags-support))

(defun c-c++/post-init-flycheck ()
  (dolist (mode '(c-mode c++-mode))
    (spacemacs/add-flycheck-hook mode))
  (when c-c++-enable-clang-support
    (spacemacs/add-to-hooks 'c-c++/load-clang-args '(c-mode-hook c++-mode-hook))))

(defun c-c++/post-init-ggtags ()
  (add-hook 'c-mode-local-vars-hook #'spacemacs/ggtags-mode-enable)
  (add-hook 'c++-mode-local-vars-hook #'spacemacs/ggtags-mode-enable))

(defun c-c++/init-gdb-mi ()
  (use-package gdb-mi
    :defer t
    :init
    (setq
     ;; use gdb-many-windows by default when `M-x gdb'
     gdb-many-windows t
     ;; Non-nil means display source file containing the main routine at startup
     gdb-show-main t)))

(defun c-c++/post-init-helm-gtags ()
  (spacemacs/helm-gtags-define-keys-for-mode 'c-mode)
  (spacemacs/helm-gtags-define-keys-for-mode 'c++-mode))

(defun c-c++/post-init-semantic ()
  (spacemacs/add-to-hooks 'semantic-mode '(c-mode-hook c++-mode-hook)))

(defun c-c++/post-init-srefactor ()
  (spacemacs/set-leader-keys-for-major-mode 'c-mode "r" 'srefactor-refactor-at-point)
  (spacemacs/set-leader-keys-for-major-mode 'c++-mode "r" 'srefactor-refactor-at-point)
  (spacemacs/add-to-hooks 'spacemacs/lazy-load-srefactor '(c-mode-hook c++-mode-hook)))

(defun c-c++/post-init-stickyfunc-enhance ()
  (spacemacs/add-to-hooks 'spacemacs/lazy-load-stickyfunc-enhance '(c-mode-hook c++-mode-hook)))

(defun c-c++/post-init-ycmd ()
  (add-hook 'c++-mode-hook 'ycmd-mode)
  (add-hook 'c-mode-hook 'ycmd-mode)
  (add-to-list 'spacemacs-jump-handlers-c++-mode '(ycmd-goto :async t))
  (add-to-list 'spacemacs-jump-handlers-c-mode '(ycmd-goto :async t))
  (dolist (mode '(c++-mode c-mode))
    (spacemacs/set-leader-keys-for-major-mode mode
      "gG" 'ycmd-goto-imprecise)))

(defun c-c++/post-init-company-ycmd ()
  (push 'company-ycmd company-backends-c-mode-common))

(defun c-c++/post-init-rtags ()
   (when c-c++-enable-rtags-support
     (setq company-rtags-begin-after-member-access nil)
      (setq rtags-completions-enabled t)

      (defun use-rtags (&optional useFileManager)
        (and (rtags-executable-find "rc")
             (cond ((not (gtags-get-rootpath)) t)
                   ((and (not (eq major-mode 'c++-mode))
                         (not (eq major-mode 'c-mode))) (rtags-has-filemanager))
                   (useFileManager (rtags-has-filemanager))
                   (t (rtags-is-indexed)))))

      (defun tags-find-symbol-at-point (&optional prefix)
        (interactive "P")
        (if (and (not (rtags-find-symbol-at-point prefix)) rtags-last-request-not-indexed)
            (helm-gtags-find-tag)))

      (defun tags-find-references-at-point (&optional prefix)
        (interactive "P")
        (if (and (not (rtags-find-references-at-point prefix)) rtags-last-request-not-indexed)
            (helm-gtags-find-rtag)))

      (defun tags-find-symbol ()
       (interactive)
       (call-interactively (if (use-rtags) 'rtags-find-symbol 'helm-gtags-find-symbol)))

     (defun tags-find-references ()
       (interactive)
        (call-interactively (if (use-rtags) 'rtags-find-references 'helm-gtags-find-rtag)))

      (defun tags-find-file ()
        (interactive)
        (call-interactively (if (use-rtags t) 'rtags-find-file 'helm-gtags-find-files)))

      (defun tags-imenu ()
        (interactive)
        (call-interactively (if (use-rtags t) 'rtags-imenu 'idomenu)))

      (dolist (mode '(c-mode c++-mode))
        (evil-leader/set-key-for-mode mode
          "m g ." 'rtags-find-symbol-at-point
          "m g ," 'rtags-find-references-at-point
          "m g v" 'rtags-find-virtuals-at-point
          "m g V" 'rtags-print-enum-value-at-point
          "m g /" 'rtags-find-all-references-at-point
          "m g Y" 'rtags-cycle-overlays-on-screen
          "m g >" 'rtags-find-symbol
          "m g <" 'rtags-find-references
          "m g [" 'rtags-location-stack-back
          "m g ]" 'rtags-location-stack-forward
          "m g D" 'rtags-diagnostics
          "m g G" 'rtags-guess-function-at-point
          "m g p" 'rtags-set-current-project
          "m g P" 'rtags-print-dependencies
          "m g e" 'rtags-reparse-file
          "m g E" 'rtags-preprocess-file
          "m g R" 'rtags-rename-symbol
          "m g M" 'rtags-symbol-info
          "m g S" 'rtags-display-summary
          "m g O" 'rtags-goto-offset
          "m g ;" 'rtags-find-file
          "m g F" 'rtags-fixit
          "m g L" 'rtags-copy-and-print-current-location
          "m g X" 'rtags-fix-fixit-at-point
          "m g B" 'rtags-show-rtags-buffer
          "m g I" 'rtags-imenu
          "m g T" 'rtags-taglist
          "m g h" 'rtags-print-class-hierarchy
          "m g a" 'rtags-print-source-arguments))

      (rtags-enable-standard-keybindings)
      (define-key c-mode-base-map (kbd "M-.") (function tags-find-symbol-at-point))
      (define-key c-mode-base-map (kbd "M-,") (function tags-find-references-at-point))
      (define-key c-mode-base-map (kbd "M-;") (function tags-find-file))
      (define-key c-mode-base-map (kbd "C-.") (function tags-find-symbol))
      (define-key c-mode-base-map (kbd "C-,") (function tags-find-references))
      (define-key c-mode-base-map (kbd "C-<") (function rtags-find-virtuals-at-point))
      (define-key c-mode-base-map (kbd "M-i") (function tags-imenu))

      (define-key global-map (kbd "M-.") (function tags-find-symbol-at-point))
      (define-key global-map (kbd "M-,") (function tags-find-references-at-point))
      (define-key global-map (kbd "M-;") (function tags-find-file))
      (define-key global-map (kbd "C-.") (function tags-find-symbol))
      (define-key global-map (kbd "C-,") (function tags-find-references))
      (define-key global-map (kbd "C-<") (function rtags-find-virtuals-at-point))
      (define-key global-map (kbd "M-i") (function tags-imenu))))

(defun c-c++/pre-init-xcscope ()
  (spacemacs|use-package-add-hook xcscope
    :post-init
    (dolist (mode '(c-mode c++-mode))
      (spacemacs/set-leader-keys-for-major-mode mode "gi" 'cscope-index-files))))

(defun c-c++/pre-init-helm-cscope ()
  (spacemacs|use-package-add-hook xcscope
    :post-init
    (dolist (mode '(c-mode c++-mode))
      (spacemacs/setup-helm-cscope mode))))
