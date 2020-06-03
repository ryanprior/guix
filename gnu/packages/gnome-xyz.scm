;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2019, 2020 Leo Prikler <leo.prikler@student.tugraz.at>
;;; Copyright © 2019 Alexandros Theodotou <alex@zrythm.org>
;;; Copyright © 2019 Giacomo Leidi <goodoldpaul@autistici.org>
;;; Copyright © 2020 Alex Griffin <a@ajgrf.com>
;;; Copyright © 2020 Jack Hill <jackhill@jackhill.us>
;;; Copyright © 2020 Ekaitz Zarraga <ekaitz@elenq.tech>
;;; Copyright © 2020 Tobias Geerinckx-Rice <me@tobias.gr>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu packages gnome-xyz)
  #:use-module (guix build-system trivial)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system meson)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages ruby)
  #:use-module (gnu packages xml))

(define-public matcha-theme
  (package
    (name "matcha-theme")
    (version "2020-05-09")
    (source
      (origin
        (method git-fetch)
        (uri
          (git-reference
            (url "https://github.com/vinceliuice/Matcha-gtk-theme")
            (commit version)))
        (file-name (git-file-name name version))
        (sha256
          (base32
            "0fp3ijynyvncy2byjjyba573p81x2pl2hdzv17mg40r8d5mjlkww"))))
    (build-system trivial-build-system)
    (arguments
     '(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let* ((out (assoc-ref %outputs "out"))
                (source (assoc-ref %build-inputs "source"))
                (bash (assoc-ref %build-inputs "bash"))
                (coreutils (assoc-ref %build-inputs  "coreutils"))
                (themesdir (string-append out "/share/themes")))
           (setenv "PATH"
                   (string-append coreutils "/bin:"
                                  (string-append bash "/bin:")))
           (copy-recursively source (getcwd))
           (patch-shebang "install.sh")
           (mkdir-p themesdir)
           (invoke "./install.sh" "-d" themesdir)
           #t))))
    (inputs
     `(("gtk-engines" ,gtk-engines)))
    (native-inputs
     `(("bash" ,bash)
       ("coreutils" ,coreutils)))
    (synopsis "Flat design theme for GTK 3, GTK 2 and GNOME-Shell")
    (description "Matcha is a flat Design theme for GTK 3, GTK 2 and
Gnome-Shell which supports GTK 3 and GTK 2 based desktop environments
like Gnome, Unity, Budgie, Pantheon, XFCE, Mate and others.")
    (home-page "https://github.com/vinceliuice/matcha")
    (license license:gpl3+)))

(define-public delft-icon-theme
  (package
    (name "delft-icon-theme")
    (version "1.12")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/madmaxms/iconpack-delft.git")
             (commit (string-append "v" version))))
       (sha256
        (base32
         "1r6b6jf793jxz15ljniwbqy3vcvsl2712qiigfrfrm46fdxlshjd"))
       (file-name (git-file-name name version))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan
       `(("." "share/icons" #:exclude ("README.md" "LICENSE" "logo.jpg")))
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-index.theme
           (lambda _
            (substitute* "Delft/index.theme"
              (("gnome") "Adwaita"))
            #t)))))
    (home-page "https://www.gnome-look.org/p/1199881/")
    (synopsis "Continuation of Faenza icon theme with up to date app icons")
    (description "Delft is a fork of the popular icon theme Faenza with up to
date app icons.  It will stay optically close to the original Faenza icons,
which haven't been updated for some years.  The new app icons are ported from
the Obsidian icon theme.")
    (license license:gpl3)))

(define-public gnome-shell-extension-appindicator
  (package
    (name "gnome-shell-extension-appindicator")
    (version "33")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url
                     "https://github.com/ubuntu/gnome-shell-extension-appindicator.git")
                    (commit (string-append "v" version))))
              (sha256
               (base32
                "0qm77s080nbf4gqnfzpwp8a7jf7lliz6fxbsd3lasvrr11pgsk87"))
              (file-name (git-file-name name version))))
    (build-system copy-build-system)
    (arguments
     `(#:install-plan
       '(("." ,(string-append "share/gnome-shell/extensions/"
                              "appindicatorsupport@rgcjonas.gmail.com")))))
    (synopsis "Adds KStatusNotifierItem support to GNOME Shell")
    (description "This extension integrates Ubuntu AppIndicators
and KStatusNotifierItems (KDE's successor of the systray) into
GNOME Shell.")
    (home-page "https://github.com/ubuntu/gnome-shell-extension-appindicator/")
    (license license:gpl2+)))

(define-public gnome-shell-extension-clipboard-indicator
  (package
    (name "gnome-shell-extension-clipboard-indicator")
    (version "34")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url (string-append "https://github.com/Tudmotu/"
                                        "gnome-shell-extension-clipboard-indicator.git"))
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0i00psc1ky70zljd14jzr627y7nd8xwnwrh4xpajl1f6djabh12s"))
              (modules '((guix build utils)))
              (snippet
               ;; Remove pre-compiled settings schemas and translations from
               ;; source, as they are generated as part of build. Upstream
               ;; includes them for people who want to run the software
               ;; directly from source tree.
               '(begin (delete-file "schemas/gschemas.compiled")
                       (for-each delete-file (find-files "locale" "\\.mo$"))
                       #t))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("." "share/gnome-shell/extensions/clipboard-indicator@tudmotu.com"
          #:include-regexp ("\\.css$" "\\.compiled$" "\\.js(on)?$" "\\.mo$" "\\.xml$")))
       #:phases
       (modify-phases %standard-phases
         (add-before 'install 'compile-schemas
           (lambda _
             (with-directory-excursion "schemas"
               (invoke "glib-compile-schemas" "."))
             #t))
         (add-before 'install 'compile-locales
           (lambda _ (invoke "./compile-locales.sh")
                   #t)))))
    (native-inputs
     `(("gettext" ,gettext-minimal)
       ("glib:bin" ,glib "bin")))       ; for glib-compile-schemas
    (home-page "https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator")
    (synopsis "Clipboard manager extension for GNOME Shell")
    (description "Clipboard Indicator is a clipboard manager for GNOME Shell
that caches clipboard history.")
    (license license:expat)))

(define-public gnome-shell-extension-topicons-redux
  (package
    (name "gnome-shell-extension-topicons-redux")
    (version "6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gitlab.com/pop-planet/TopIcons-Redux.git")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1dli9xb545n3xlj6q4wl0y5gzkm903zs47p8fiq71pdvbr6v38rj"))))
    (build-system gnu-build-system)
    (native-inputs
     `(("glib" ,glib "bin")))
    (arguments
     `(#:tests? #f                      ;no test defined in the project
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'build)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out")))
               (invoke "make"
                       "install"
                       (string-append
                        "INSTALL_PATH="
                        out
                        "/share/gnome-shell/extensions"))))))))
    (home-page "https://gitlab.com/pop-planet/TopIcons-Redux")
    (synopsis "Display legacy tray icons in the GNOME Shell top panel")
    (description "Many applications, such as chat clients, downloaders, and
some media players, are meant to run long-term in the background even after you
close their window.  These applications remain accessible by adding an icon to
the GNOME Shell Legacy Tray.  However, the Legacy Tray was removed in GNOME
3.26.  TopIcons Redux brings those icons back into the top panel so that it's
easier to keep track of apps running in the backround.")
    (license license:gpl2+)))

(define-public gnome-shell-extension-dash-to-dock
  (package
    (name "gnome-shell-extension-dash-to-dock")
    (version "67")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/micheleg/dash-to-dock.git")
                    (commit (string-append "extensions.gnome.org-v"
                                           version))))
              (sha256
               (base32
                "1746xm0iyvyzj6m3pvjx11smh9w1s7naz426ki0dlr5l7jh3mpy5"))
              (file-name (git-file-name name version))))
    (build-system gnu-build-system)
    (arguments
     '(#:tests? #f
       #:make-flags (list (string-append "INSTALLBASE="
                                         (assoc-ref %outputs "out")
                                         "/share/gnome-shell/extensions"))
       #:phases
       (modify-phases %standard-phases
         (delete 'bootstrap)
         (delete 'configure))))
    (native-inputs
     `(("glib:bin" ,glib "bin")
       ("intltool" ,intltool)
       ("pkg-config" ,pkg-config)))
    (propagated-inputs
     `(("glib" ,glib)))
    (synopsis "Transforms GNOME's dash into a dock")
    (description "This extension moves the dash out of the
overview, transforming it into a dock for easier application launching and
faster window switching.")
    (home-page "https://micheleg.github.io/dash-to-dock/")
    (license license:gpl2+)))

(define-public gnome-shell-extension-gsconnect
  (package
    (name "gnome-shell-extension-gsconnect")
    ;; v33 is the last version to support GNOME 3.34
    (version "33")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url (string-append "https://github.com/andyholmes"
                                        "/gnome-shell-extension-gsconnect.git"))
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1q03axhn75i864vgmd6myhmgwrmnpf01gsd1wl0di5x9q8mic2zn"))))
    (build-system meson-build-system)
    (arguments
     `(#:configure-flags
       (let* ((out (assoc-ref %outputs "out"))
              (name+version (strip-store-file-name out))
              (gschema-dir (string-append out
                                          "/share/gsettings-schemas/"
                                          name+version
                                          "/glib-2.0/schemas"))
              (gnome-shell (assoc-ref %build-inputs "gnome-shell"))
              (openssh (assoc-ref %build-inputs "openssh"))
              (openssl (assoc-ref %build-inputs "openssl")))
         (list
          (string-append "-Dgnome_shell_libdir=" gnome-shell "/lib")
          (string-append "-Dgsettings_schemadir=" gschema-dir)
          (string-append "-Dopenssl_path=" openssl "/bin/openssl")
          (string-append "-Dsshadd_path=" openssh "/bin/ssh-add")
          (string-append "-Dsshkeygen_path=" openssh "/bin/ssh-keygen")
          (string-append "-Dsession_bus_services_dir=" out "/share/dbus-1/services")
          "-Dpost_install=true"))
       #:phases
       (modify-phases %standard-phases
         (add-before 'configure 'fix-paths
           (lambda* (#:key inputs #:allow-other-keys)
             (let* ((glib (assoc-ref inputs "glib:bin"))
                    (gapplication (string-append glib "/bin/gapplication"))
                    (gi-typelib-path (getenv "GI_TYPELIB_PATH")))
               (substitute* "data/org.gnome.Shell.Extensions.GSConnect.desktop"
                 (("gapplication") gapplication))
               (for-each
                (lambda (file)
                  (substitute* file
                    (("'use strict';")
                     (string-append "'use strict';\n\n"
                                    "'" gi-typelib-path "'.split(':').forEach("
                                    "path => imports.gi.GIRepository.Repository."
                                    "prepend_search_path(path));"))))
                '("src/extension.js" "src/prefs.js"))
               #t)))
         (add-after 'install 'wrap-daemons
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (service-dir
                     (string-append out "/share/gnome-shell/extensions"
                                    "/gsconnect@andyholmes.github.io/service"))
                    (gi-typelib-path (getenv "GI_TYPELIB_PATH")))
               (wrap-program (string-append service-dir "/daemon.js")
                 `("GI_TYPELIB_PATH" ":" prefix (,gi-typelib-path)))
               #t))))))
    (inputs
     `(("at-spi2-core" ,at-spi2-core)
       ("caribou" ,caribou)
       ("evolution-data-server" ,evolution-data-server)
       ("gjs" ,gjs)
       ("glib" ,glib)
       ("glib:bin" ,glib "bin")
       ("gsound" ,gsound)
       ("gnome-shell" ,gnome-shell)
       ("gtk+" ,gtk+)
       ("nautilus" ,nautilus)
       ("openssh" ,openssh)
       ("openssl" ,openssl)
       ("python-nautilus" ,python-nautilus)
       ("python-pygobject" ,python-pygobject)
       ("upower" ,upower)))
    (native-inputs
     `(("gettext" ,gettext-minimal)
       ("gobject-introspection" ,gobject-introspection)
       ("libxml2" ,libxml2)
       ("pkg-config" ,pkg-config)))
    (home-page "https://github.com/andyholmes/gnome-shell-extension-gsconnect/wiki")
    (synopsis "Connect GNOME Shell with your Android phone")
    (description "GSConnect is a complete implementation of KDE Connect
especially for GNOME Shell, allowing devices to securely share content, like
notifications or files, and other features like SMS messaging and remote
control.")
    (license license:gpl2)))

(define-public gnome-shell-extension-hide-app-icon
  (let ((commit "4188aa5f4ba24901a053a0c3eb0d83baa8625eab")
        (revision "0"))
    (package
      (name "gnome-shell-extension-hide-app-icon")
      (version (git-version "2.7" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url (string-append "https://github.com/michael-rapp"
                                   "/gnome-shell-extension-hide-app-icon.git"))
               (commit commit)))
         (sha256
          (base32
           "1i28n4bz6wrhn07vpxkr6l1ljyn7g8frp5xrr11z3z32h2hxxcd6"))
         (file-name (git-file-name name version))))
      (build-system gnu-build-system)
      (arguments
       '(#:tests? #f                ; no test target
         #:make-flags (list (string-append "EXTENSIONS_DIR="
                                           (assoc-ref %outputs "out")
                                           "/share/gnome-shell/extensions"))
         #:phases
         (modify-phases %standard-phases
           (delete 'configure)      ; no configure script
           (replace 'install
             (lambda* (#:key outputs #:allow-other-keys)
               (let ((out (assoc-ref outputs "out"))
                     (pre "/share/gnome-shell/extensions/")
                     (dir "hide-app-icon@mrapp.sourceforge.com"))
                 (copy-recursively dir (string-append out pre dir))
                 #t))))))
      (native-inputs
       `(("glib" ,glib "bin")
         ("intltool" ,intltool)))
      (propagated-inputs
       `(("glib" ,glib)))
      (synopsis "Hide app icon from GNOME's panel")
      (description "This extension hides the icon and/or title of the
currently focused application in the top panel of the GNOME shell.")
      (home-page
       "https://github.com/michael-rapp/gnome-shell-extension-hide-app-icon/")
      (license
        ;; README.md and LICENSE.txt disagree -- the former claims v3, the
        ;; latter v2.  No mention of "or later" in either place or in the code.
        (list license:gpl2
              license:gpl3)))))

(define-public gnome-shell-extension-dash-to-panel
  (package
    (name "gnome-shell-extension-dash-to-panel")
    (version "26")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/home-sweet-gnome/dash-to-panel.git")
                    (commit (string-append "v" version))))
              (sha256
               (base32
                "1phfx2pblygpcvsppsqqqflm7qnz46mqkw29hj0nv2dn69hf4xbc"))
              (file-name (git-file-name name version))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:make-flags (list (string-append "INSTALLBASE="
                                         (assoc-ref %outputs "out")
                                         "/share/gnome-shell/extensions")
                          (string-append "VERSION="
                                         ,(package-version
                                           gnome-shell-extension-dash-to-panel)))
       #:phases
       (modify-phases %standard-phases
         (delete 'bootstrap)
         (delete 'configure))))
    (native-inputs
     `(("intltool" ,intltool)
       ("pkg-config" ,pkg-config)))
    (propagated-inputs
     `(("glib" ,glib)
       ("glib" ,glib "bin")))
    (synopsis "Icon taskbar for GNOME Shell")
    (description "This extension moves the dash into the gnome main
panel so that the application launchers and system tray are combined
into a single panel, similar to that found in KDE Plasma and Windows 7+.")
    (home-page "https://github.com/home-sweet-gnome/dash-to-panel/")
    (license license:gpl2+)))

(define-public gnome-shell-extension-noannoyance
  (package
    (name "gnome-shell-extension-noannoyance")
    (version "5")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/BjoernDaase/noannoyance.git")
                    (commit "e37b5b3c31f577b4698bc6659bc9fec5ea9ac5d4")))
              (sha256
               (base32
                "0fa8l3xlh8kbq07y4385wpb908zm6x53z81q16xlmin97dln32hh"))
              (file-name (git-file-name name version))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("." "share/gnome-shell/extensions/noannoyance@daase.net"))))
    (synopsis "Remove 'Window is ready' annotation")
    (description "One of the many extensions that remove this message.
It uses ES6 syntax and claims to be more actively maintained than others.")
    (home-page "https://extensions.gnome.org/extension/2182/noannoyance/")
    (license license:gpl2)))

(define-public gnome-shell-extension-paperwm
  (package
    (name "gnome-shell-extension-paperwm")
    (version "36.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/paperwm/PaperWM.git")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1ssnabwxrns36c61ppspjkr9i3qifv08pf2jpwl7cjv3pvyn4kly"))
              (snippet
               '(begin (delete-file "schemas/gschemas.compiled")))))
    (build-system copy-build-system)
    (arguments
     '(#:install-plan
       '(("." "share/gnome-shell/extensions/paperwm@hedning:matrix.org"
          #:include-regexp ("\\.js(on)?$" "\\.css$" "\\.ui$" "\\.png$"
                            "\\.xml$" "\\.compiled$")))
       #:phases
       (modify-phases %standard-phases
         (add-before 'install 'compile-schemas
           (lambda _
             (with-directory-excursion "schemas"
               (invoke "make"))
             #t)))))
    (native-inputs
     `(("glib:bin" ,glib "bin"))) ; for glib-compile-schemas
    (home-page "https://github.com/paperwm/PaperWM")
    (synopsis "Tiled scrollable window management for GNOME Shell")
    (description "PaperWM is an experimental GNOME Shell extension providing
scrollable tiling of windows and per monitor workspaces.  It's inspired by paper
notebooks and tiling window managers.")
    (license license:gpl3)))

(define-public numix-gtk-theme
  (package
    (name "numix-gtk-theme")
    (version "2.6.7")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/numixproject/numix-gtk-theme.git")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "12mw0kr0kkvg395qlbsvkvaqccr90cmxw5rrsl236zh43kj8grb7"))))
    (build-system gnu-build-system)
    (arguments
     '(#:make-flags
       (list (string-append "INSTALL_DIR="
                            (assoc-ref %outputs "out")
                            "/share/themes/Numix"))
       #:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))             ; no configure script
    (native-inputs
     `(("glib:bin" ,glib "bin")             ; for glib-compile-schemas
       ("gnome-shell" ,gnome-shell)
       ("gtk+" ,gtk+)
       ("xmllint" ,libxml2)
       ("ruby-sass" ,ruby-sass)))
    (synopsis "Flat theme with light and dark elements")
    (description "Numix is a modern flat theme with a combination of light and
dark elements.  It supports GNOME, Unity, Xfce, and Openbox.")
    (home-page "https://numixproject.github.io")
    (license license:gpl3+)))

(define-public numix-theme
  (deprecated-package "numix-theme" numix-gtk-theme))

(define-public papirus-icon-theme
  (let ((version "0.0.0") ;; The package does not use semver
        (revision "1")
        (tag "20200430"))
    (package
      (name "papirus-icon-theme")
      (version (git-version version revision tag))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git")
               (commit tag)))
         (sha256
          (base32
           "19dfiifc7cjwy0nb1hgzryzaijszsyix303xsgk5xbmhpwrv92hq"))
         (file-name (git-file-name name version))))
      (build-system gnu-build-system)
    (arguments
     '(#:tests? #f
       #:make-flags (list (string-append "PREFIX=" (assoc-ref %outputs "out")))
       #:phases
       (modify-phases %standard-phases
         (delete 'bootstrap)
         (delete 'configure)
         (delete 'build))))
      (native-inputs
       `(("gtk+:bin" ,gtk+ "bin")))
      (home-page "https://git.io/papirus-icon-theme")
      (synopsis "Fork of Paper icon theme with a lot of new icons and a few extras")
      (description "Papirus is a fork of the icon theme Paper with a lot of new icons
and a few extra features.")
      (license license:gpl3))))

(define-public vala-language-server
  (package
    (name "vala-language-server")
    ;; Note to maintainer: VLS must be built with a Vala toolchain the same
    ;; version or newer. Therefore when you update this package you may need
    ;; to update Vala too.
    (version "0.48")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/benwaffle/vala-language-server.git")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32 "0chgfpci247skrvsiq1l8cas8sj2z6z42dlarka3df3qwxmh0if0"))))
    (build-system meson-build-system)
    (arguments '(#:glib-or-gtk? #t))
    (inputs
     `(("jsonrpc-glib" ,jsonrpc-glib)
       ("libgee" ,libgee)
       ("json-glib" ,json-glib)))
    (native-inputs
     `(("glib" ,glib)
       ("pkg-config" ,pkg-config)
       ("vala" ,vala-0.48)))
    (home-page "https://github.com/benwaffle/vala-language-server")
    (synopsis "Language server for Vala")
    (description "The Vala language server is an implementation of the Vala
language specification for the Language Server Protocol (LSP).  This tool is
used in text editing environments to provide a complete and integrated
feature-set for programming Vala effectively.")
    (license license:lgpl2.1+)))
