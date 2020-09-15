\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{src/archives}

\ProcessOptions\relax

\LoadClass[a4paper]{report}  

\makeatletter
\newcommand\mynobreakpar{\par\nobreak\@afterheading} 
\makeatother

\newcommand{\tsectionfmt}[3]{#1{\bf #2.\nobreak}#3\mynobreakpar}
\renewenvironment{part}[1]{\tsectionfmt{\underline}{#1}{}}{}

\RequirePackage{soul}
\RequirePackage{environ}
\RequirePackage{mathtools}
\RequirePackage{amsmath}
\RequirePackage{amsfonts}
\RequirePackage{xcolor}
\RequirePackage{tikz}
\RequirePackage{calc}
\RequirePackage{xintexpr}
\RequirePackage[many]{tcolorbox}
\RequirePackage{parskip}
\RequirePackage{fullpage}
\RequirePackage{suffix}
\RequirePackage[pdftex, pdfborderstyle={/S/U/W 0}]{hyperref}
\RequirePackage{catchfile}
\RequirePackage{xifthen}
\RequirePackage[top=0.5in, bottom=0.7in, left=1in, right=1in, includeheadfoot, headsep=20pt]{geometry}
\setlength{\headheight}{16pt}

\usetikzlibrary{calc}
% --- general notation ---
\newcommand{\listgen}[3]{\ensuremath{#1_#2, \ldots, #1_{#3}}}
\newcommand{\listof}[2]{\listgen{#1}{1}{#2}}
\newcommand{\listn}[1]{\listof{#1}{n}}

\def\P{{\rm Pr}}
\def\R{\mathbb R}
\def\E{\mathbb E}

\DeclareMathOperator*{\argmax}{arg\,max}
\DeclareMathOperator*{\argmin}{arg\,min}

\def\noteop #1 #2{\overset{\text{(#1)}}{#2}}
\def\edots#1#2#3{#1_{#2},\ldots,#1_{#3}}

\def\placeholder#1{\hskip 0pt {\rm\color{gray}{[#1]}}}
\def\todo{\placeholder{TODO}}
\def\mtodo{\text{\todo}}

\def\ctext#1{$$\text{#1}$$}
% ---

\newif\iffull
\newif\ifln
\fullfalse
\lnfalse

% --- colors ---
\definecolor{___gray}{rgb}{0.95, 0.95, 0.95}
\definecolor{__gray}{rgb}{0.85, 0.85, 0.85}
\definecolor{_gray}{rgb}{0.70, 0.70, 0.70}
\definecolor{gray}{rgb}{0.50, 0.50, 0.50}
\definecolor{blue}{rgb}{0.56, 0.74, 0.86}
\definecolor{red}{rgb}{1, 0.51, 0.56}
\definecolor{green}{rgb}{0.53, 0.66, 0.42}

\def\hlg#1{\hlc[___gray]{#1}}

\newcommand{\hlc}[2][yellow]{{%
  \colorlet{tempcolor}{#1}%
  \sethlcolor{tempcolor}\hl{#2}}%
}
% ---

% --- command processing ---
\def\runcmd#1{\immediate\write18{#1}}

\def\readcmd#1#2{%
  \CatchFileDef{\cftemp}{|"#1"}{}%
  \expandafter\def\expandafter#2\expandafter{\expandafter\stripspace\cftemp\next}%
}%

\def\stripspace#1 \next{#1}
\def\root{src}
% ---

% --- linking ---
\def\ln#1#2{%
  %\ifln%
  %  #2%
  %\else%
    \lntrue
    \iffull%
    \hyperlink{#1}{#2}%
    \else%
    \href{#1}{#2}%
    \fi%
    \lnfalse
  %\fi%
}

% specially formatted link 
\newcommand\lnfmt[5][]{%
  \def\templntext{\fmtln[#1]{#3}{#4}{#5}}%
  \ln{#2}{\templntext}%
}

% "local" reference link
\newcommand\lnl[4][]{%
    \readcmd{cat \curr/#2/#3/metadata/refnum}{\refnum}%
	\iffull%
		\def\temppath{\currreference/#2/#3}%
    \global\edef\templabel{\temppath_}%
    \hypertarget{\templabel}{}%
		\lnfmt[#1]{\temppath}{#4}{\csname #2d\endcsname}{\refnum}%
	\else%
		\lnfmt[#1]{#2/#3/ref.pdf}{#4}{\csname #2d\endcsname}{\refnum}%
	\fi%
}

% "global" reference link
\def\lngraw#1#2{%
  \iffull\def\temp{#1}\else\getrelpathln{#1}{\temp}\fi%
  \ln{\temp}{#2}%
}

% "global" reference link
\newcommand\lng[4][]{%
  \readcmd{cat \root/#3/metadata/refnum}{\refnum}%
  \iffull\def\temp{#3}\else\getrelpathln{#3}{\temp}\fi%
  \lnfmt[#1]{\temp}{#4}{\csname #2d\endcsname}{\refnum}%
}

\newcommand\refln[4][]{\lnl[#1]{#2}{#3}{#4}}
\newcommand\reflnenv[5][]{\lnl[#1]{#2}{#3}{#4}\refenvl{#2}{#3}{#5}}
\newcommand\reflng[4][]{\lng[#1]{#2}{#3}{#4}}
\newcommand\mreflng[3][]{\lng[#1]{#2}{#3}{\enm{\ldots}}}
\newcommand\reflnm[3][]{\lnl[#1]{#2}{#3}{\enm{\ldots}}}

\newcommand\fmtln[4][]{%
  \ifthenelse{\equal{#1}{}}%
  {%
    $\color{blue}[$\color{black}#2$\color{blue}]_{\tt{}#3}^{\tt{}#4}$%
  }%
  {%
    $\color{blue}\left[\text{\color{black}#2}\color{blue}\right]\!_{\tt{}#3}^{\tt{}#4}$%
  }%
}

\def\firstreflist{}

\makeatletter
\newcommand{\labeltext}[1]{%
  \@bsphack
  \csname phantomsection\endcsname % in case hyperref is used
  \def\@currentlabel{#1}{\label{#1}}%
  \@esphack
}
\makeatother

\MakeRobust{\ref}% avoid expanding it when in a textual label
% ---

% --- references ---
\def\includereference#1{
  \begin{reference}{#1}
    \input{\curr/ref.tex}
  \end{reference}
}

\def\includedefs#1{
  \begin{reference}{#1}
    \CatchFileDef{\cftemp}{|"\root/scripts/format_defs.sh '\curr'"}{}%
    \cftemp
  \end{reference}
}

\def\defvisualizer#1#2{
  \begin{tcolorbox}[title={\tt \char`\\#1}, colback=black!1, colbacktitle=white, coltitle=black, colframe=black!70, arc=0.1mm, boxrule=0.1pt]
    #2
  \end{tcolorbox}
}

\newenvironment{reference}[1]
{
  \def\currreference{#1}
  \newpage
  \iffull
    \hypertarget{#1}{}
  \fi
  \def\curr{\root/#1}
  \gdef\currpath{\pathfmt{#1}}
  %\setcounter{page}{1}
  \pagestyle{fancy}
  \fancyhead[R]{\currpath}
  \inheritdefs{\curr}
}
{
}

\def\refenvl#1#2#3{{\bnosp\inheritdefs{\curr/#1/#2}\enosp{}#3}}

\newenvironment{refenv}[2]
{
  \bgroup
  \inheritdefs{\curr/#1/#2}
}
{
  \egroup
}

\NewEnviron{ralign}{%
	\def\n{\nonumber}
  \begin{align}
    \BODY \nonumber
  \end{align}
}
% ---

% --- reference path formatting ---
\def\getrelpathln#1#2{\readcmd{python \root/scripts/relpathln.py "\curr" "\root/#1"}{#2}}

\def\gend#1{{\color{blue!90!black} #1}}
\def\proofd{\gend{P}}
\def\noted{\gend{N}}
\def\topicd{\gend{T}}
\def\definitiond{\gend{D}}

\def\pathfmt#1{\readcmd{python \root/scripts/path_fmt.py "#1" "\iffull F\else N\fi"}{\temp}\temp}
% ---

% --- boxes ---
\newenvironment{mytcb}[1][]
{
  \begin{tcolorbox}[breakable, #1]
  \parskip=10pt
}
{
  \end{tcolorbox}
}

\newenvironment{proposition}[1][Proposition \currpath.]
{
  \begin{mytcb}[title={#1}, 
    colback=blue!5, colbacktitle=blue!20, coltitle=black, colframe=blue!60!black,
    arc=0.1mm, boxrule=0.5pt]
}
{
  \end{mytcb}
}

\def\propfmtrel#1{Proposition \pathfmt{\currreference/proof/#1}.}

\newenvironment{proof}
{
  \begin{mytcb}[title={Proof.}, 
    colbacktitle=___gray, coltitle=black, colback=white, colframe=gray!80!black,
    arc=0.1mm, boxrule=0.5pt]
}
{
    \end{mytcb}
}

\newenvironment{note}[1][Note \currpath.]
{
  \begin{mytcb}[title={#1}, 
    colback=_gray!15, colbacktitle=_gray!30, coltitle=black, colframe=_gray!60!black,
    arc=0.1mm, boxrule=0.5pt]
}
{
  \end{mytcb}
}

\newenvironment{definition}[1][Definition \currpath.]
{
  \begin{mytcb}[title={#1}, 
    colback=blue!5, colbacktitle=blue!20, coltitle=black, colframe=blue!60!black,
    arc=0.1mm, boxrule=0.5pt]
}
{
  \end{mytcb}
}

% ---

% --- header ---
\RequirePackage{fancyhdr}
\pagestyle{fancy}

\renewcommand{\headrulewidth}{0pt}
% ---

\def\inheritdefs#1{\readcmd{\root/scripts/defs_inheritance.sh "#1"}{\defsinherited} \defsinherited}

\def\sc{\setcounter}
\def\nc{\newcounter}
\def\defl#1#2{\expandafter\gdef\csname #1\endcsname{#2}}
\def\getl#1{\csname #1\endcsname}

\nc{a}
\nc{b}
\nc{c}
\nc{d}

\def\ifbool{\xintifboolexpr}
\def\defeq{\coloneqq}

\renewcommand{\labelitemi}{--}
\renewcommand{\labelitemii}{--}
\renewcommand{\labelitemiii}{--}
\renewcommand{\labelitemiv}{--}

\makeatletter
\newcommand*{\Ifinlist}[2]{%
  \edef\tempa{#1}%
  \edef\tempb{#2}%
  \expandafter\expandafter\expandafter\in@\expandafter\expandafter\expandafter{\expandafter\expandafter\expandafter,\expandafter\tempa\expandafter,\expandafter}\expandafter{\expandafter,\tempb,}%
  \ifin@
    \expandafter\@firstoftwo
  \else
    \expandafter\@secondoftwo
  \fi
}
\makeatother

\def\rinclude#1{\include{\curr/#1}}

\newenvironment{rtitlepage}
{
  \setcounter{a}{\thepage}
  \begin{titlepage}
  \setcounter{page}{\thea}
  \stepcounter{a}
  \centering
  \vspace*{3in}
}
{
  \thispagestyle{fancy}
  \end{titlepage}
  \newpage
  \setcounter{page}{\thea}
}

\def\srulen{\hrule}
\def\srule{\vspace{10pt}\srulen}
\def\srulei{\vspace{4pt}\srule}

\def\bnosp{\edef\xspaceskiporig{\the\xspaceskip}\edef\spacefactororig{\the\spacefactor}\let\parorig\par\spacefactor=10000\xspaceskip=0.00001pt\let\par\relax}
\def\enosp{\spacefactor=\spacefactororig\xspaceskip=\xspaceskiporig\let\par\parorig}

\def\enm#1{\ensuremath{{#1}}}

\def\rellrgf#1#2#3#4#5{\relrgf{\rellgf{#1}{#2}{#3}}{#4}{#5}}
\def\rellgf#1#2#3{\underset{\raisebox{#3}{\makebox[0pt]{\scriptsize \tt \colorbox{blue!30}{#2}}}}{#1}}
\def\relrgf#1#2#3{\overset{\raisebox{#3}{\makebox[0pt]{\scriptsize \tt \colorbox{___gray}{#2}}}}{#1}}
\def\rellf#1#2{\rellgf{#1}{#2}{-5pt}}
\def\relrf#1#2{\relrgf{#1}{#2}{8pt}}
\def\rellrf#1#2#3{\relrf{\rellf{#1}{#2}}{#3}}
\def\rell #1 #2 {\rellf{#1}{#2}}
\def\relr #1 #2 {\relrf{#1}{#2}}
\def\relrg #1 #2 #3 {\relrgf{#1}{#2}{#3}}
\def\rellr #1 #2 #3 {\rellrf{#1}{#2}{#3}}
\def\relis{\text{ is }}
\def\defined{\text{defined}}