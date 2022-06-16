import Foundation

extension BenchmarkRunner {
  mutating func addCSS() {
    let r = "--([a-zA-Z0-9_-]+)\\s*:\\s*(.*?):"
    
    // sorry
    let css = """
    html {
        font-size: 100%;
        -ms-text-size-adjust: 100%;
        -webkit-text-size-adjust:100%
    }

    body {
        margin: 0;
        padding: 0;
        background-color: var(--color-fill);
        color:var(--color-text)
    }

    ul, ol, li, dl, dt, dd, h1, h2, h3, h4, h5, h6, hgroup, p, blockquote, figure, form, fieldset, input, legend, pre, abbr {
        margin: 0;
        padding:0
    }

    pre, code, address, caption, th, figcaption {
        font-size: 1em;
        font-weight: normal;
        font-style:normal
    }

    fieldset, iframe, img {
        width: 100%;
        border:none
    }

    caption, th {
        text-align:left
    }

    table {
        border-collapse: collapse;
        border-spacing:0
    }

    article, aside, footer, header, nav, main, section, summary, details, hgroup, figure, figcaption {
        display:block
    }

    audio, canvas, video, progress {
        display: inline-block;
        vertical-align:baseline
    }

    button {
        font: inherit;
        vertical-align:middle
    }

    nav a:link, nav a:visited, nav a:hover, nav a:active {
        text-decoration:none
    }

    :root {
        --border-radius: 4px;
        --content-margin-bottom: 1em
    }

    body {
        color-scheme: light dark;
        --logo-reference: url('/assets/images/swift.svg');
        --menu-icon: url('/assets/images/icon-menu.svg');
        --menu-icon-close: url('/assets/images/icon-close.svg');
        --color-nav-background: var(--color-fill-secondary);
        --color-nav-rule: rgb(230, 230, 230);
        --color-active-menu-group: #2a2a2a;
        --color-fill: #fff;
        --color-fill-secondary: #f7f7f7;
        --color-fill-tertiary: #f0f0f0;
        --color-fill-quaternary: #282828;
        --color-fill-blue: blue;
        --color-fill-gray: #ccc;
        --color-fill-gray-secondary: #f5f5f5;
        --color-fill-green-secondary: #f0fff0;
        --color-fill-orange-secondary: #fffaf6;
        --color-fill-red-secondary: #fff0f5;
        --color-figure-blue: #36f;
        --color-figure-gray: #000;
        --color-figure-gray-secondary: #666;
        --color-figure-gray-secondary-alt: #666;
        --color-figure-gray-tertiary: #666;
        --color-figure-green: green;
        --color-figure-light-gray: #666;
        --color-figure-orange: #c30;
        --color-figure-red: red;
        --color-tutorials-teal: #000;
        --color-article-background: var(--color-fill-tertiary);
        --color-article-body-background: var(--color-fill);
        --color-aside-deprecated: var(--color-figure-gray);
        --color-aside-deprecated-background: var(--color-fill-orange-secondary);
        --color-aside-deprecated-border: var(--color-figure-orange);
        --color-aside-experiment: var(--color-figure-gray);
        --color-aside-experiment-background: var(--color-fill-gray-secondary);
        --color-aside-experiment-border: var(--color-figure-light-gray);
        --color-aside-important: var(--color-figure-gray);
        --color-aside-important-background: var(--color-fill-gray-secondary);
        --color-aside-important-border: var(--color-figure-light-gray);
        --color-aside-note: var(--color-figure-gray);
        --color-aside-note-background: var(--color-fill-gray-secondary);
        --color-aside-note-border: var(--color-figure-light-gray);
        --color-aside-tip: var(--color-figure-gray);
        --color-aside-tip-background: var(--color-fill-gray-secondary);
        --color-aside-tip-border: var(--color-figure-light-gray);
        --color-aside-warning: var(--color-figure-gray);
        --color-aside-warning-background: var(--color-fill-red-secondary);
        --color-aside-warning-border: var(--color-figure-red);
        --color-badge-default: var(--color-figure-light-gray);
        --color-badge-beta: var(--color-figure-gray-tertiary);
        --color-badge-deprecated: var(--color-figure-orange);
        --color-badge-dark-default: #b0b0b0;
        --color-badge-dark-beta: #b0b0b0;
        --color-badge-dark-deprecated: #f60;
        --color-button-background: var(--color-fill-blue);
        --color-button-background-active: #36f;
        --color-button-background-hover: var(--color-figure-blue);
        --color-button-text: #fff;
        --color-call-to-action-background: var(--color-fill-secondary);
        --color-changes-added: var(--color-figure-light-gray);
        --color-changes-added-hover: var(--color-figure-light-gray);
        --color-changes-deprecated: var(--color-figure-light-gray);
        --color-changes-deprecated-hover: var(--color-figure-light-gray);
        --color-changes-modified: var(--color-figure-light-gray);
        --color-changes-modified-hover: var(--color-figure-light-gray);
        --color-changes-modified-previous-background: var(--color-fill-gray-secondary);
        --color-code-background: var(--color-fill-secondary);
        --color-code-collapsible-background: var(--color-fill-tertiary);
        --color-code-collapsible-text: var(--color-figure-gray-secondary-alt);
        --color-code-line-highlight: rgba(51, 102, 255, 0.08);
        --color-code-line-highlight-border: var(--color-figure-blue);
        --color-code-plain: var(--color-figure-gray);
        --color-content-table-content-color: var(--color-fill-secondary);
        --color-dropdown-background: rgba(255, 255, 255, 0.8);
        --color-dropdown-border: #ccc;
        --color-dropdown-option-text: #666;
        --color-dropdown-text: #000;
        --color-dropdown-dark-background: rgba(255, 255, 255, 0.1);
        --color-dropdown-dark-border: rgba(240, 240, 240, 0.2);
        --color-dropdown-dark-option-text: #ccc;
        --color-dropdown-dark-text: #fff;
        --color-eyebrow: var(--color-figure-gray-secondary);
        --color-focus-border-color: var(--color-fill-blue);
        --color-focus-color: rgba(0, 125, 250, 0.6);
        --color-form-error: var(--color-figure-red);
        --color-form-error-background: var(--color-fill-red-secondary);
        --color-form-valid: var(--color-figure-green);
        --color-form-valid-background: var(--color-fill-green-secondary);
        --color-generic-modal-background: var(--color-fill);
        --color-grid: var(--color-fill-gray);
        --color-header-text: var(--color-figure-gray);
        --color-hero-eyebrow: #ccc;
        --color-link: var(--color-figure-blue);
        --color-loading-placeholder-background: var(--color-fill);
        --color-nav-color: #666;
        --color-nav-current-link: rgba(0, 0, 0, 0.6);
        --color-nav-expanded: #fff;
        --color-nav-hierarchy-collapse-background: #f0f0f0;
        --color-nav-hierarchy-collapse-borders: #ccc;
        --color-nav-hierarchy-item-borders: #ccc;
        --color-nav-keyline: rgba(0, 0, 0, 0.2);
        --color-nav-link-color: #000;
        --color-nav-link-color-hover: #36f;
        --color-nav-outlines: #ccc;
        --color-nav-solid-background: #fff;
        --color-nav-sticking-expanded-keyline: rgba(0, 0, 0, 0.1);
        --color-nav-stuck: rgba(255, 255, 255, 0.9);
        --color-nav-uiblur-expanded: rgba(255, 255, 255, 0.9);
        --color-nav-uiblur-stuck: rgba(255, 255, 255, 0.7);
        --color-nav-root-subhead: var(--color-tutorials-teal);
        --color-nav-dark-border-top-color: rgba(255, 255, 255, 0.4);
        --color-nav-dark-color: #b0b0b0;
        --color-nav-dark-current-link: rgba(255, 255, 255, 0.6);
        --color-nav-dark-expanded: #2a2a2a;
        --color-nav-dark-hierarchy-collapse-background: #424242;
        --color-nav-dark-hierarchy-collapse-borders: #666;
        --color-nav-dark-hierarchy-item-borders: #424242;
        --color-nav-dark-keyline: rgba(66, 66, 66, 0.95);
        --color-nav-dark-link-color: #fff;
        --color-nav-dark-link-color-hover: #09f;
        --color-nav-dark-outlines: #575757;
        --color-nav-dark-rule: #575757;
        --color-nav-dark-solid-background: #000;
        --color-nav-dark-sticking-expanded-keyline: rgba(66, 66, 66, 0.7);
        --color-nav-dark-stuck: rgba(42, 42, 42, 0.9);
        --color-nav-dark-uiblur-expanded: rgba(42, 42, 42, 0.9);
        --color-nav-dark-uiblur-stuck: rgba(42, 42, 42, 0.7);
        --color-nav-dark-root-subhead: #fff;
        --color-runtime-preview-background: var(--color-fill-tertiary);
        --color-runtime-preview-disabled-text: rgba(102, 102, 102, 0.6);
        --color-runtime-preview-text: var(--color-figure-gray-secondary);
        --color-secondary-label: var(--color-figure-gray-secondary);
        --color-step-background: var(--color-fill-secondary);
        --color-step-caption: var(--color-figure-gray-secondary);
        --color-step-focused: var(--color-figure-light-gray);
        --color-step-text: var(--color-figure-gray-secondary);
        --color-svg-icon: #666;
        --color-syntax-attributes: rgb(148, 113, 0);
        --color-syntax-characters: rgb(39, 42, 216);
        --color-syntax-comments: rgb(112, 127, 140);
        --color-syntax-documentation-markup: rgb(80, 99, 117);
        --color-syntax-documentation-markup-keywords: rgb(80, 99, 117);
        --color-syntax-heading: rgb(186, 45, 162);
        --color-syntax-keywords: rgb(173, 61, 164);
        --color-syntax-marks: rgb(0, 0, 0);
        --color-syntax-numbers: rgb(39, 42, 216);
        --color-syntax-other-class-names: rgb(112, 61, 170);
        --color-syntax-other-constants: rgb(75, 33, 176);
        --color-syntax-other-declarations: rgb(4, 124, 176);
        --color-syntax-other-function-and-method-names: rgb(75, 33, 176);
        --color-syntax-other-instance-variables-and-globals: rgb(112, 61, 170);
        --color-syntax-other-preprocessor-macros: rgb(120, 73, 42);
        --color-syntax-other-type-names: rgb(112, 61, 170);
        --color-syntax-param-internal-name: rgb(64, 64, 64);
        --color-syntax-plain-text: rgb(0, 0, 0);
        --color-syntax-preprocessor-statements: rgb(120, 73, 42);
        --color-syntax-project-class-names: rgb(62, 128, 135);
        --color-syntax-project-constants: rgb(45, 100, 105);
        --color-syntax-project-function-and-method-names: rgb(45, 100, 105);
        --color-syntax-project-instance-variables-and-globals: rgb(62, 128, 135);
        --color-syntax-project-preprocessor-macros: rgb(120, 73, 42);
        --color-syntax-project-type-names: rgb(62, 128, 135);
        --color-syntax-strings: rgb(209, 47, 27);
        --color-syntax-type-declarations: rgb(3, 99, 140);
        --color-syntax-urls: rgb(19, 55, 255);
        --color-tabnav-item-border-color: var(--color-fill-gray);
        --color-text: var(--color-figure-gray);
        --color-text-background: var(--color-fill);
        --color-tutorial-assessments-background: var(--color-fill-secondary);
        --color-tutorial-background: var(--color-fill);
        --color-tutorial-navbar-dropdown-background: var(--color-fill);
        --color-tutorial-navbar-dropdown-border: var(--color-fill-gray);
        --color-tutorial-quiz-border-active: var(--color-figure-blue);
        --color-tutorials-overview-background: #161616;
        --color-tutorials-overview-content: #fff;
        --color-tutorials-overview-content-alt: #fff;
        --color-tutorials-overview-eyebrow: #ccc;
        --color-tutorials-overview-icon: #b0b0b0;
        --color-tutorials-overview-link: #09f;
        --color-tutorials-overview-navigation-link: #ccc;
        --color-tutorials-overview-navigation-link-active: #fff;
        --color-tutorials-overview-navigation-link-hover: #fff;
        --color-tutorial-hero-text: #fff;
        --color-tutorial-hero-background: #000
    }

    body[data-color-scheme="light"] {
        color-scheme: light
    }

    body[data-color-scheme="dark"] {
        color-scheme:dark
    }

    @media screen {
        body[data-color-scheme="dark"] {
            --logo-reference: url('/assets/images/swift~dark.svg');
            --menu-icon: url('/assets/images/icon-menu~dark.svg');
            --menu-icon-close: url('/assets/images/icon-close~dark.svg');
            --color-nav-background: var(--color-fill-tertiary);
            --color-nav-rule: #424242;
            --color-active-menu-group: #f0f0f0;
            --color-fill: #000;
            --color-fill-secondary: #161616;
            --color-fill-tertiary: #2a2a2a;
            --color-fill-blue: #06f;
            --color-fill-gray: #575757;
            --color-fill-gray-secondary: #222;
            --color-fill-green-secondary: #030;
            --color-fill-orange-secondary: #472400;
            --color-fill-red-secondary: #300;
            --color-figure-blue: #09f;
            --color-figure-gray: #fff;
            --color-figure-gray-secondary: #ccc;
            --color-figure-gray-secondary-alt: #b0b0b0;
            --color-figure-gray-tertiary: #b0b0b0;
            --color-figure-green: #090;
            --color-figure-light-gray: #b0b0b0;
            --color-figure-orange: #f60;
            --color-figure-red: #f33;
            --color-tutorials-teal: #fff;
            --color-article-body-background: rgb(17, 17, 17);
            --color-button-background-active: #06f;
            --color-code-line-highlight: rgba(0, 153, 255, 0.08);
            --color-dropdown-background: var(--color-dropdown-dark-background);
            --color-dropdown-border: var(--color-dropdown-dark-border);
            --color-dropdown-option-text: var(--color-dropdown-dark-option-text);
            --color-dropdown-text: var(--color-dropdown-dark-text);
            --color-nav-color: var(--color-nav-dark-color);
            --color-nav-current-link: var(--color-nav-dark-current-link);
            --color-nav-expanded: var(--color-nav-dark-expanded);
            --color-nav-hierarchy-collapse-background: var(--color-nav-dark-hierarchy-collapse-background);
            --color-nav-hierarchy-collapse-borders: var(--color-nav-dark-hierarchy-collapse-borders);
            --color-nav-hierarchy-item-borders: var(--color-nav-dark-hierarchy-item-borders);
            --color-nav-keyline: var(--color-nav-dark-keyline);
            --color-nav-link-color: var(--color-nav-dark-link-color);
            --color-nav-link-color-hover: var(--color-nav-dark-link-color-hover);
            --color-nav-outlines: var(--color-nav-dark-outlines);
            --color-nav-solid-background: var(--color-nav-dark-solid-background);
            --color-nav-sticking-expanded-keyline: var(--color-nav-dark-sticking-expanded-keyline);
            --color-nav-stuck: var(--color-nav-dark-stuck);
            --color-nav-uiblur-expanded: var(--color-nav-dark-uiblur-expanded);
            --color-nav-uiblur-stuck: var(--color-nav-dark-uiblur-stuck);
            --color-runtime-preview-disabled-text: rgba(204, 204, 204, 0.6);
            --color-syntax-attributes: rgb(204, 151, 104);
            --color-syntax-characters: rgb(217, 201, 124);
            --color-syntax-comments: rgb(127, 140, 152);
            --color-syntax-documentation-markup: rgb(127, 140, 152);
            --color-syntax-documentation-markup-keywords: rgb(163, 177, 191);
            --color-syntax-keywords: rgb(255, 122, 178);
            --color-syntax-marks: rgb(255, 255, 255);
            --color-syntax-numbers: rgb(217, 201, 124);
            --color-syntax-other-class-names: rgb(218, 186, 255);
            --color-syntax-other-constants: rgb(167, 235, 221);
            --color-syntax-other-declarations: rgb(78, 176, 204);
            --color-syntax-other-function-and-method-names: rgb(178, 129, 235);
            --color-syntax-other-instance-variables-and-globals: rgb(178, 129, 235);
            --color-syntax-other-preprocessor-macros: rgb(255, 161, 79);
            --color-syntax-other-type-names: rgb(218, 186, 255);
            --color-syntax-param-internal-name: rgb(191, 191, 191);
            --color-syntax-plain-text: rgb(255, 255, 255);
            --color-syntax-preprocessor-statements: rgb(255, 161, 79);
            --color-syntax-project-class-names: rgb(172, 242, 228);
            --color-syntax-project-constants: rgb(120, 194, 179);
            --color-syntax-project-function-and-method-names: rgb(120, 194, 179);
            --color-syntax-project-instance-variables-and-globals: rgb(120, 194, 179);
            --color-syntax-project-preprocessor-macros: rgb(255, 161, 79);
            --color-syntax-project-type-names: rgb(172, 242, 228);
            --color-syntax-strings: rgb(255, 129, 112);
            --color-syntax-type-declarations: rgb(107, 223, 255);
            --color-syntax-urls: rgb(102, 153, 255);
            --color-tutorial-background: var(--color-fill-tertiary)
        }
    }

    .highlight {
        background:var(--color-code-background)
    }

    .highlight .c, .highlight .cm, .highlight .cp, .highlight .c1, .highlight .cs {
        color:var(--color-syntax-comments)
    }

    .highlight .k, .highlight .kc, .highlight .kd, .highlight .kp, .highlight .kr, .highlight .kt .nb {
        color:var(--color-syntax-keywords)
    }

    .highlight .nv, .highlight .nf {
        color:color(--color-syntax-project-constants)
    }

    .highlight .s, .highlight .sb, .highlight .sc, .highlight .sd, .highlight .s2, .highlight .se, .highlight .sh, .highlight .si, .highlight .s1, .highlight .sx {
        color:var(--color-syntax-strings)
    }

    .highlight .na {
        color:var(--color-syntax-attributes)
    }

    .highlight .nc, .highlight .ni, .highlight .no, .highlight .vc, .highlight .vg, .highlight .vi {
        color:var(--color-syntax-other-type-names)
    }

    .highlight .err, .highlight .gr, .highlight .gt, .highlight .ne {
        color:var(--color-syntax-strings)
    }

    .highlight .m, .highlight .mf, .highlight .mh, .highlight .mi, .highlight .il, .highlight .mo {
        color:var(--color-syntax-numbers)
    }

    .highlight .o, .highlight .ow, .highlight .gs {
        font-weight:bold
    }

    .highlight .ge {
        font-style:italic
    }

    .highlight .nt {
        color:var(--color-syntax-characters)
    }

    .highlight .gd, .highlight .gd .x {
        color: var(--color-syntax-plain-text);
        background-color:var(--color-fill-red-secondary)
    }

    .highlight .gi, .highlight .gi .x {
        color: var(--color-syntax-plain-text);
        background-color:color(--color-fill-green-secondary)
    }

    .highlight .gh, .highlight .bp, .highlight .go, .highlight .gp, .highlight .gu, .highlight .w {
        color:var(--color-syntax-comments)
    }

    .highlight .nn {
        color:var(--color-syntax-other-declarations)
    }

    .highlight .sr {
        color:var(--color-figure-green)
    }

    .highlight .ss {
        color:var(--color-syntax-heading)
    }
    .language-console {
        color:var(--color-syntax-plain-text)
    }
    
    *, * :before, * :after {
        -moz-box-sizing: border-box;
        -webkit-box-sizing: border-box;
        box-sizing:border-box
    }
    
    html, body {
        height:100%
    }
    
    body {
        font-family: -apple-system, BlinkMacSystemFont, "SF Hello", "Helvetica Neue", Helvetica, Arial, Verdana, sans-serif;
        font-size: 18px;
        line-height: 1.5;
        background-color: var(--color-fill);
        color: var(--color-text);
        font-weight:300
    }
    
    body pre, body code {
        font-family: "SF Mono", Menlo, Consolas, Monaco, "Courier New", monospace, serif
    }
    
    a:link {
        color: var(--color-link);
        text-decoration:none
    }
    
    a:visited {
        color:var(--color-link)
    }
    
    a:active {
        color:var(--color-link)
    }
    
    a:hover {
        color: var(--color-link);
        text-decoration:underline
    }
    
    p {
        margin-bottom:1em
    }
    
    h1 {
        margin-bottom: 0.5em;
        font-size: 3em;
        font-weight: 300;
        line-height:1
    }
    
    h1.active + .main-nav {
        border-top:1px solid var(--color-active-menu-group)
    }
    
    h2 {
        margin-bottom: 0.5em;
        font-size: 2.5em;
        font-weight: 300;
        line-height:1
    }
    
    h3 {
        margin-bottom: 0.5em;
        font-size: 1.5em;
        font-weight: 300;
        line-height:1
    }
    
    h4 {
        margin-bottom: 0.5em;
        font-size: 1.25em;
        font-weight: 300;
        line-height:1.2
    }
    
    h5 {
        margin-bottom: 0.5em;
        font-size: 1.175em;
        font-weight: 500;
        line-height:1.4
    }
    
    h6 {
        margin-bottom: 0.5em;
        font-size: 1em;
        font-weight: 700;
        line-height:1.5
    }
    
    h1, h2, h3, h4, h5, h6 {
        color:var(--color-header-text)
    }
    
    div.highlighter-rouge {
        margin-left:13px
    }
    
    pre {
        font-size: 14px;
        line-height: 1.6em;
        border-left: 5px solid var(--color-code-line-highlight-border);
        margin: 0.5em 0 1.5em 10px;
        padding: 4px 0 2px 10px;
        overflow:scroll
    }
    
    a > code, p > code, li > code, dd > code, blockquote > code, td > code {
        padding: 0;
        margin: 0;
        font-size: 16px;
        white-space: nowrap;
        background-color:transparent
    }
    
    p > code, li > code, dd > code, blockquote > code, td > code {
        color:var(--color-code-plain)
    }
    
    p > code {
        white-space: pre-wrap;
        word-break:break-word
    }
    
    hr {
        border: none;
        border-top: 1px var(--color-dropdown-border) solid;
        margin:2em 0
    }
    
    hr:last-child {
        display:none
    }
    
    details {
        margin-bottom:2em
    }
    
    details :first-child {
        margin-top:1.5em
    }
    
    cite {
        display:block
    }
    
    cite:before {
        content: "— "
    }
    
    #logo {
        text-indent: -9999px;
        height: 48px;
        width: 100%;
        margin-top: 20px;
        margin-bottom: 0.5em;
        padding-bottom:10px
    }
    
    #logo a {
        display: block;
        width: 190px;
        height: 48px;
        background-image: var(--logo-reference);
        background-repeat: no-repeat;
        background-size: 190px 48px;
        background-position-x: -8px
    }
    
    nav[role="navigation"] {
        width: 250px;
        position: fixed;
        overflow: scroll;
        left: 0;
        top: 0;
        bottom: 0;
        background: var(--color-nav-background);
        color: var(--color-nav-color);
        border-right: 1px solid var(--color-nav-rule);
        padding: 20px 30px
    }
    
    nav[role="navigation"] ul {
        border-top: 1px solid var(--color-nav-rule);
        font-weight: 400;
        margin-bottom: 30px;
        list-style: none
    }
    
    nav[role="navigation"] ul ul {
        list-style: none
    }
    
    nav[role="navigation"] ul li {
        border-bottom: 1px solid var(--color-nav-rule)
    }
    
    nav[role="navigation"] ul li.active {
        border-bottom: 1px solid var(--color-active-menu-group)
    }
    
    nav[role="navigation"] ul li.active a {
        font-weight: 700
    }
    
    nav[role="navigation"] ul li a:link {
        color: var(--color-nav-link-color);
        text-decoration: none;
        text-transform: uppercase;
        letter-spacing: 1px;
        font-size: 12px;
        display: block;
        padding: 10px
    }
    
    nav[role="navigation"] ul li a:visited {
        color: var(--color-nav-link-color)
    }
    
    nav[role="navigation"] ul li a:active {
        font-weight: 700
    }
    
    nav[role="navigation"] ul li a:hover {
        color: var(--color-link)
    }
    
    nav[role="navigation"] ul li ul {
        margin-bottom: 10px;
        border-top: none
    }
    
    nav[role="navigation"] ul li ul li {
        border-bottom: none;
        padding: 0.1em
    }
    
    nav[role="navigation"] ul li ul li.active {
        border-bottom: none
    }
    
    nav[role="navigation"] ul li ul li.active a {
        font-weight: 700
    }
    
    nav[role="navigation"] ul li ul a:link {
        color: var(--color-nav-link-color);
        text-decoration: none;
        text-transform: none;
        letter-spacing: 0;
        font-size: 12px;
        display: block;
        margin-left: 15px;
        padding: 0 0 3px;
        border-bottom: none;
        font-weight: 300
    }
    
    nav[role="navigation"] ul li ul a:hover {
        color: var(--color-link)
    }
    
    nav[role="navigation"] h2 {
        font-size: 0.75em;
        font-weight: 700;
        text-transform: lowercase;
        font-variant: small-caps;
        color: var(--color-figure-gray-secondary-alt);
        padding-bottom:0.5em
    }
    
    main {
        max-width: 798px;
        min-width: 320px;
        margin-left: 250px;
        padding: 35px 30px 0;
        min-height: 100%;
        height: auto !important;
        height: 100%
    }
    
    footer[role="contentinfo"] {
        background: var(--color-nav-background);
        border-top: 1px solid var(--color-nav-rule);
        color: var(--color-nav-color);
        padding: 20px 30px;
        margin-left: 250px;
        min-height: 74px
    }
    
    footer[role="contentinfo"] p {
        font-size: 0.625em;
        color: var(--color-nav-link-color);
        line-height: 1em;
        margin-bottom: 1em;
        margin-bottom: var(--content-margin-bottom)
    }
    
    footer[role="contentinfo"] p.privacy a {
        color: var(--color-nav-link-color);
        border-right: 1px solid var(--color-nav-rule);
        margin-right: 6px;
        padding-right: 8px
    }
    
    footer[role="contentinfo"] p.privacy a:last-child {
        border: none;
        margin: 0;
        padding: 0
    }
    
    footer[role="contentinfo"] p:last-child {
        margin-bottom: 0
    }
    
    footer[role="contentinfo"] aside {
        position: relative;
        width: 100%;
        max-width: 700px
    }
    
    footer[role="contentinfo"] aside i {
        width: 16px;
        height: 16px;
        background-repeat: no-repeat;
        background-size: 16px;
        display: block;
        margin-left: 1em;
        float: right
    }
    
    footer[role="contentinfo"] aside i.twitter {
        background-image: url("/assets/images/icon-twitter.svg")
    }
    
    footer[role="contentinfo"] aside i.feed {
        background-image: url("/assets/images/icon-feed.svg")
    }
    
    article:first-of-type {
        padding-bottom:36px
    }
    
    article h2 {
        padding-top:1.1em
    }
    
    article h3 {
        padding-top:1em
    }
    
    article h4 {
        padding-top: 1em;
        border-bottom: 1px var(--color-dropdown-border) solid;
        padding-bottom:0.5em
    }
    
    article h5 {
        margin-top:1em
    }
    
    article header {
        width: 100%;
        display: inline-block;
        padding-bottom:2.5em
    }
    
    article header h1 {
        padding-bottom:0.125em
    }
    
    article header .byline {
        float: left;
        font-size: 14px;
        margin-bottom:1em
    }
    
    article header .byline img {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        border: 1px var(--color-fill-gray) solid;
        position: absolute;
        margin-right: 0.25em;
        margin-top:-6px
    }
    
    article header .byline span {
        padding-left:42px
    }
    
    article header .about {
        float: none;
        clear: both;
        font-size: 14px;
        font-weight: 400;
        color: var(--color-figure-gray-tertiary);
        border-left: 1px var(--color-figure-gray-tertiary) solid;
        margin: 23px 3em 23px 0;
        padding:4px 0 4px 10px
    }
    
    article header time {
        float: left;
        text-transform: uppercase;
        font-size: 14px;
        font-weight: 400;
        color: var(--color-figure-gray-tertiary);
        margin-right: 3em;
        margin-bottom:1em
    }
    
    article header .tags {
        display: block;
        font-size: 12px;
        font-weight: 400;
        margin-top:0
    }
    
    article:not(:first-of-type) {
        border-top: 1px solid var(--color-figure-gray-tertiary);
        padding:36px 0
    }
    
    article blockquote {
        border-left: 5px var(--color-fill-gray) solid;
        margin: 0.5em 0 23px 1em;
        padding: 4px 0 2px 10px;
        color: var(--color-aside-note);
        overflow-x:auto
    }
    
    article blockquote p:last-child {
        margin-bottom:0
    }
    
    article ul, article ol {
        padding-left: 40px;
        margin:1em 0
    }
    
    article ul ul, article ul ol, article ol ul, article ol ol {
        margin:0
    }
    
    article ul {
        list-style:disc
    }
    
    article ul ul {
        list-style:circle
    }
    
    article ul ul ul {
        list-style:square
    }

    article ol {
        list-style:decimal
    }
    
    article dl {
        margin:2em 0 1em 0
    }
    
    article dl:after {
        content: "";
        display: table;
        clear:both
    }
    
    article dl dt {
        float: left;
        clear: right;
        margin-right: 1em;
        display: block;
        width: 28%;
        text-align:right
    }
    
    article dl dd {
        float: right;
        width: 65%;
        margin-bottom: 1em;
        overflow:scroll
    }
    
    article dl dd {
        padding-bottom: 1em;
        border-bottom:1px var(--color-dropdown-border) solid
    }
    
    article table {
        display: block;
        overflow-x: auto;
        width: max-content;
        min-width: 68%;
        max-width: 100%;
        margin: 2em auto 3em auto;
        border-collapse: separate;
        border:1px var(--color-dropdown-border) solid
    }
    
    article table th {
        font-weight: 700;
        text-align:center
    }
    
    article table th, article table td {
        width: 50%;
        padding: 0.5em 1.5em;
        border-bottom:1px var(--color-dropdown-border) solid
    }
    
    article table th:not(:first-child), article table td:not(:first-child) {
        border-left:1px var(--color-dropdown-border) solid
    }
    
    article table tr:last-child td {
        border-bottom:none
    }
    
    article details {
        margin-top: 0;
        cursor:pointer
    }
    
    article details summary {
        display: list-item;
        padding-bottom: 0.5em;
        outline: none;
        margin-top:0
    }
    
    article details summary:after {
        content: "Expand";
        text-transform: lowercase;
        font-variant: small-caps;
        border-bottom:1px var(--color-fill-gray) dashed
    }
    
    article details[open] summary:after {
        content: "Collapse"
    }
    
    article details[open] * :not(summary) {
        cursor:auto
    }
    
    article details.download {
        margin-top: 0;
        cursor:pointer
    }
    
    article details.download table {
        display:inline-table
    }
    
    article details.download summary {
        padding-bottom: 0.5em;
        outline: none;
        margin-top:0
    }
    
    article details.download summary:after {
        content: none;
        text-transform: lowercase;
        font-variant: small-caps;
        border-bottom:1px var(--color-fill-gray) dashed
    }
    
    article details.download[open] summary:after {
        content:none
    }
    
    article details.download[open] * :not(summary) {
        cursor:auto
    }
    
    article > details {
        margin-left:40px
    }
    
    article .good pre, article pre.good {
        background: var(--color-fill-green-secondary);
        border-color:var(--color-figure-green)
    }
    
    article .good pre:before, article pre.good:before {
        content: "✅";
        float:right
    }
    
    article .bad pre, article pre.bad {
        background: var(--color-fill-red-secondary);
        border-color:var(--color-figure-red)
    }
    
    article .bad pre:before, article pre.bad:before {
        content: "⛔️";
        float:right
    }
    
    article .links ul {
        list-style:none
    }
    
    article .links ul ul {
        list-style: disc;
        margin-top:5px
    }
    
    article .links a:after {
        content: " ›"
    }
    
    article .links .link-external:after, article .links-external a:after, article .link-external:after {
        content: " ↗"
    }
    
    article .links-download a:after {
        content: " ⬇"
    }
    
    article .links-list-nostyle ul {
        padding-left:0
    }
    
    article .links-list-nostyle ul ul {
        list-style:none
    }
    
    article .links-sublevel p {
        margin-bottom:0
    }
    
    article .links-sublevel ul {
        margin-top: 0;
        padding-left:40px
    }
    
    article footer {
        margin: 4em 0 0 0;
        padding: 1.5em 0 1em 0;
        border-top:1px var(--color-dropdown-border) solid
    }
    
    article footer:after {
        content: "";
        display: table;
        clear: both
    }
    
    article footer nav [rel="prev"] {
        width: 45%;
        float: left;
        text-align: left
    }
    
    article footer nav [rel="prev"]:before {
        content: "← "
    }
    
    article footer nav [rel="next"] {
        width: 45%;
        float: right;
        text-align: right
    }
    
    article footer nav [rel="next"]:after {
        content: " →"
    }
    
    .title a:link, .title a:visited {
        color:var(--color-header-text)
    }
    
    .alert, .danger, .warning, .info, .success {
        border-width: 1px;
        border-style: solid;
        padding: 0.5em;
        margin:0.5em 0 1.5em 0
    }
    
    .alert a, .danger a, .warning a, .info a, .success a {
        word-break:break-word
    }
    
    .alert p:first-child, .danger p:first-child, .warning p:first-child, .info p:first-child, .success p:first-child {
        margin-top:0
    }
    
    .alert p:last-child, .danger p:last-child, .warning p:last-child, .info p:last-child, .success p:last-child {
        margin-bottom:0
    }
    
    .alert code, .danger code, .warning code, .info code, .success code {
        border: none;
        background: transparent;
        padding:0
    }
    
    code {
        white-space:pre-line
    }
    
    pre code {
        white-space:inherit
    }
    
    pre code .graphic {
        font-size: 19px;
        line-height:0
    }
    
    pre code .commentary, pre code .graphic {
        font-family: "SF Hello", "Helvetica Neue", Helvetica, Arial, Verdana, sans-serif
    }
    
    @supports (overflow: -webkit-marquee) and(justify-content: inherit) {
        .alert:before, .danger:before, .warning:before, .info:before, .success:before {
            font-size: 1em;
            float: left;
            clear: left;
            padding-left: 0.125em;
            width:2em
        }
    
        .alert p, .danger p, .warning p, .info p, .success p {
            padding-left:2em
        }
    
        .success:before {
            content: "✅"
        }
    
        .info:before {
            content: "ℹ️"
        }
    
        .warning:before {
            content: "⚠️"
        }
    
        .danger:before {
            content: "❗️"
        }
    }
    
    .success {
        color: var(--color-aside-note);
        border-color: var(--color-form-valid);
        background-color:var(--color-form-valid-background)
    }
    
    .info {
        color: var(--color-aside-note);
        border-color: var(--color-aside-note-border);
        background-color:var(--color-aside-note-background)
    }
    
    .warning {
        color: var(--color-aside-deprecated);
        border-color: var(--color-aside-deprecated-border);
        background-color:var(--color-aside-deprecated-background)
    }
    
    .danger {
        color: var(--color-aside-warning);
        border-color: var(--color-aside-warning-border);
        background-color:var(--color-aside-warning-background)
    }
    
    table.downloads {
        width: 100%;
        table-layout:fixed
    }
    
    table.downloads th {
        font-size:0.75em
    }
    
    table.downloads .platform {
        width:40%
    }
    
    table.downloads .download {
        width:60%
    }
    
    table.downloads .download a.debug, table.downloads .download a.signature {
        font-size: 0.7em;
        display:block
    }
    
    table.downloads .download a {
        font-weight: 700;
        font-size:1em
    }
    
    table.downloads .download a:not([download]) {
        font-weight:400
    }
    
    table.downloads .download a:not([download]):before {
        content: "("
    }
    
    table.downloads .download a:not([download]):after {
        content: ")"
    }
    
    table.downloads .arch-tag {
        width:60%
    }
    
    table.downloads .arch-tag a.debug, table.downloads .arch-tag a.signature {
        font-size: 0.7em;
        display:block
    }
    
    table.downloads .arch-tag a {
        font-weight: 700;
        font-size:1em
    }
    
    table.downloads .arch-tag a:not([arch-tag]) {
        font-weight:400
    }
    
    article input.detail[type=checkbox] {
        visibility: hidden;
        cursor: pointer;
        height: 0;
        width: 100%;
        margin-bottom: 2em;
        display: block;
        font-size: inherit;
        font-style: inherit;
        font-weight: inherit;
        font-family: inherit;
        position: relative;
        top:-.85rem
    }
    
    article p + input.detail[type=checkbox] {
        margin-top:auto
    }
    
    article .screenonly {
        display:none
    }
    
    @media screen {
        article .screenonly {
            display:inherit
        }
    
        article input.detail[type=checkbox]:before {
            content: "▶ ";
            visibility: visible;
            font-size:80%
        }
    
        article input.detail[type=checkbox]:after {
            text-transform: lowercase;
            font-variant: small-caps;
            border-bottom: 1px var(--color-fill-gray) dashed;
            color: var(--color-figure-gray-secondary);
            content: "More detail";
            visibility:visible
        }
    
        article input.detail[type=checkbox]:checked:before {
            content: "▼ "
        }
    
        article input.detail[type=checkbox]:checked:after {
            content: "Less detail"
        }
    
        article input.detail[type=checkbox] + .more {
            transition:0.5s opacity ease, 0.5s max-height ease
        }
    
        article input.detail[type=checkbox]:checked + .more {
            visibility: visible;
            max-height:1000rem
        }
    
        article input.detail[type=checkbox]:not(:checked) + .more {
            overflow: hidden;
            max-height: 0px;
            opacity:0
        }
    }
    
    article .more > p:first-of-type {
        margin-top:0
    }
    
    .color-scheme-toggle {
        display: block;
        outline: none;
        --toggle-color-fill: var(--color-button-background);
        font-size: 12px;
        border: 1px solid var(--color-nav-link-color);
        border-radius: var(--border-radius);
        display: inline-flex;
        padding: 1px;
        margin-bottom:var(--content-margin-bottom)
    }
    
    .color-scheme-toggle input {
        position: absolute;
        clip: rect(1px, 1px, 1px, 1px);
        clip-path: inset(0px 0px 99.9% 99.9%);
        overflow: hidden;
        height: 1px;
        width: 1px;
        padding: 0;
        border: 0;
        appearance:none
    }
    
    .color-scheme-toggle-label {
        border: 1px solid transparent;
        border-radius: var(--toggle-border-radius-inner, 2px);
        color: var(--color-nav-link-color);
        display: inline-block;
        text-align: center;
        padding: 1px 6px;
        min-width: 42px;
        box-sizing:border-box
    }
    
    .color-scheme-toggle-label:hover {
        cursor:pointer
    }
    
    input:checked + .color-scheme-toggle-label {
        background: var(--color-nav-link-color);
        color: var(--color-nav-stuck)
    }
    
    [role="contentinfo"] {
        display: flex;
        justify-content:space-between
    }
    
    .visuallyhidden {
        position: absolute;
        clip: rect(1px, 1px, 1px, 1px);
        clip-path: inset(0px 0px 99.9% 99.9%);
        overflow: hidden;
        height: 1px;
        width: 1px;
        padding: 0;
        border:0
    }
    
    @media only screen and (max-width: 767px) {
        nav[role="navigation"] {
            width: 100%;
            position: relative;
            border-bottom: 1px solid var(--color-nav-rule);
            border-right: none;
            padding: 20px 30px;
            overflow: hidden
        }
    
        nav.open[role="navigation"] .list-items {
            display: block
        }
    
        nav[role="navigation"] .list-items {
            padding-top: var(--content-margin-bottom);
            display:none
        }
    
        .menu-toggle {
            content: ' ';
            height: 20px;
            width: 20px;
            background-image: var(--menu-icon-close);
            background-repeat: no-repeat;
            background-position: center center;
            cursor:pointer
        }
    
        .menu-toggle.open {
            background-image:var(--menu-icon)
        }
    
        #logo {
            margin: 0;
            padding:0
        }
    
        #logo a {
            margin:0 auto
        }
    
        main {
            max-width: 100%;
            min-width: 320px;
            margin-left: 0;
            padding: 30px 30px 0
        }
    
        footer[role="contentinfo"] {
            margin-left: 0;
            flex-direction:column
        }
    
        .footer-other {
            display: flex;
            justify-content: space-between;
            margin-top:var(--content-margin-bottom)
        }
    
        h1 {
            font-size: 48px;
            font-weight: 300;
            line-height:1
        }
    
        h2 {
            font-size: 40px;
            font-weight: 300;
            line-height:1.1
        }
    
        h3 {
            font-size: 38px;
            font-weight: 300;
            line-height:1.1
        }
    
        h4 {
            font-size: 36px;
            font-weight: 300;
            line-height:1.2
        }
    
        h5 {
            font-size: 24px;
            font-weight: 500;
            line-height:1.4
        }
    
        h6 {
            font-size: 18px;
            font-weight: 700;
            line-height:1.5
        }
    
        div.highlighter-rouge {
            margin-left:0
        }
    
        article blockquote {
            margin-left:0.5em
        }
    
        table.downloads {
            border:1px var(--color-dropdown-border) solid
        }
    
        table.downloads, table.downloads thead, table.downloads tbody, table.downloads th, table.downloads td, table.downloads tr {
            display:block !important
        }
    
        table.downloads thead tr {
            position: absolute;
            top: -9999px;
            left:-9999px
        }
    
        table.downloads tr {
            border:1px solid var(--color-dropdown-border)
        }
    
        table.downloads td {
            border-left: none !important;
            border-right: none !important;
            border-bottom: 1px solid var(--color-dropdown-border) !important;
            position: relative;
            padding-left: 35%;
            width:100% !important
        }
    
        table.downloads td:before {
            position: absolute;
            top: 0.5em;
            left: 0.5em;
            width: 27.5%;
            padding-right: 10px;
            white-space: nowrap;
            text-align:right
        }
    
        table.downloads td.platform:before {
            content: "Platform"
        }
    
        table.downloads td.download:before {
            content: "Download";
            top:1em
        }
    
        table.downloads td.date:before {
            content: "Date"
        }
    
        table.downloads td.toolchain:before {
            content: "Toolchain";
            top:1em
        }
    
        table.downloads td.github-tag:before {
            content: "GitHub Tag"
        }
    
        table.downloads td.docker-tag:before {
            content: "Docker Tag"
        }
    
        table.downloads td.arch-tag:before {
            content: "Architecture"
        }
    }
    
    .nav-menu-container {
        display: grid;
        grid-template-columns: 1fr;
        grid-template-rows: 1fr;
        align-items:center
    }
    
    .menu-item {
        grid-area:1 / 1 / 1 / 1
    }
    
    .logo-container {
        justify-self:center
    }
    
    .menu-toggle {
        justify-self:right
    }
    
    @media only print {
        html body {
            background: white;
            font-size: 12pt;
            padding:0.5in
        }
    
        html body * {
            -webkit-print-color-adjust:exact
        }
    
        a {
            color: black !important;
            text-decoration: underline !important
        }
    
        a[href^="http:"]:after {
            content: " (" attr(href) ") ";
            color:#444
        }
    
        h1, h2, h3, h4, h5, h6, p, article > div, pre, table {
            page-break-inside:avoid
        }
    
        details:not([open]) {
            visibility:visible
        }
    
        details:not([open]) summary {
            display:none !important
        }
    
        details:not([open]) > *, details:not([open]) {
            display:block
        }
    
        .alert, .success, .info, .warning, .danger {
            margin:1.5em 0
        }
    
        main {
            width: auto;
            padding: 0;
            border: 0;
            float: none !important;
            color: black;
            background: transparent;
            margin: 0;
            max-width: 100%;
            min-height: 1in
        }
    
        nav[role="navigation"] {
            background: transparent;
            border: none;
            width: auto;
            position: static;
            padding: 0
        }
    
        nav[role="navigation"] h2, nav[role="navigation"] ul {
            display: none
        }
    
        nav[role="navigation"] #logo {
            position: static;
            margin-bottom: 1.5em
        }
    
        nav[role="navigation"] #logo a {
            background-position: -15px
        }
    
        footer[role="contentinfo"] {
            display: none
        }
    }
    
    /*# sourceMappingURL=application.css.map */
    """
    let cssRegex = Benchmark(
      name: "cssRegex",
      regex: try! Regex(r),
      ty: .allMatches,
      target: css
    )

    let cssRegexNS = NSBenchmark(
      name: "cssRegexNS",
      regex: try! NSRegularExpression(pattern: r),
      ty: .all,
      target: css
    )
    register(cssRegex)
    register(cssRegexNS)
  }
}
