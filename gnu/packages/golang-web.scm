;;; Copyright © 2021 Ryan Prior <rprior@protonmail.com>

(define-module (gnu packages golang-web)
  #:use-module (gnu packages base)
  #:use-module (gnu packages golang)
  #:use-module (guix build-system go)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))

(define-public go-github-com-puerkitobio-urlesc
  (package
    (name "go-github-com-puerkitobio-urlesc")
    (version "de5bf2ad457846296e2031421a34e2568e304e35")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/PuerkitoBio/urlesc")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0n0srpqwbaan1wrhh2b7ysz543pjs1xw2rghvqyffg9l0g8kzgcw"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/PuerkitoBio/urlesc"))
    (home-page "https://github.com/PuerkitoBio/urlesc")
    (synopsis "Implements query escaping as per RFC 3986")
    (description
     "This package escapes queries as per RFC 3986.  It contains some parts of
the @code{net/url} package, modified so as to allow some reserved characters
incorrectly escaped by net/url.")
    (license license:expat)))

(define-public go-github-com-puerkitobio-purell
  (package
    (name "go-github-com-puerkitobio-purell")
    (version "1.1.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/PuerkitoBio/purell")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0c525frsxmalrn55hzzsxy17ng8avkd40ga0wxfw9haxsdjgqdqy"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/PuerkitoBio/purell"))
    (propagated-inputs
     `(("go-github-com-puerkitobio-urlesc" ,go-github-com-puerkitobio-urlesc)
       ("go-golang-org-x-net" ,go-golang-org-x-net)
       ("go-golang-org-x-text" ,go-golang-org-x-text)))
    (home-page "https://github.com/PuerkitoBio/purell")
    (synopsis "Normalizes URLs")
    (description
     "This package provides a library to normalize URLs.  It returns a pure
URL (a Pure-ell.)  Based on the Wikipedia article for URLs and RFC 3986.")
    (license license:expat)))

(define-public go-github-com-gomarkdown-markdown
  (package
    (name "go-github-com-gomarkdown-markdown")
    (version "8c8b3816f167b780c855b6412793ffd5de35ef05")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/gomarkdown/markdown")
             (commit  version)))
       (file-name (git-file-name name "master"))
       (sha256
        (base32
         "141l462gxjqhk58s92h0v73wjvavgn9x8yfj9dmjq5s8ckxqfs8q"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/gomarkdown/markdown"))
    (home-page "https://github.com/gomarkdown/markdown")
    (synopsis "Markdown parser and HTML renderer for golang.")
    (description
     "This package provides a library for parsing Markdown documents and
rendering them to HTML.  It supports common extensions.")
    (license license:expat)))
