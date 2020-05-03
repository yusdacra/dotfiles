/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx       = 0;   /* border pixel of windows */
static const unsigned int snap           = 16;  /* snap pixel */
static const unsigned int gappih         = 0;  /* horiz inner gap between windows */
static const unsigned int gappiv         = 0;  /* vert inner gap between windows */
static const unsigned int gappoh         = 0;   /* horiz outer gap between windows and screen edge */
static const unsigned int gappov         = 0;   /* vert outer gap between windows and screen edge */
static const int smartgaps               = 0;   /* 1 means no outer gap when there is only one window */
static const int showbar                 = 1;   /* 0 means no bar */
static const int topbar                  = 1;   /* 0 means bottom bar */
static const int horizpadbar             = 3;   /* horizontal padding for statusbar */
static const int vertpadbar              = 3;   /* vertical padding for statusbar */
static const int focusonnetactive        = 0;   /* 0 means default behaviour, 1 means auto-focus on urgent window */
static const int attachmode              = 2;   /* 0 = master (default), 1 = above, 2 = aside, 3 = below, 4 = bottom */
static const int pertag                  = 1;   /* 0 means global layout across all tags (default), 1 = layout per tag (pertag) */
static const int pertagbar               = 0;   /* 0 means using pertag, but with the same barpos, 1 = normal pertag */
static const int zoomswap                = 1;   /* 0 means default behaviour, 1 = zoomswap patch */
static const int fancybar                = 1;   /* 0 means default behaviour, 1 = fancybar patch */
static const int savefloats              = 1;   /* 0 means default behaviour, 1 = savefloats patch */
static const int losefullscreen          = 1;   /* 0 means default behaviour, 1 = losefullscreen patch */
static const int nrg_force_vsplit        = 1;   /* nrowgrid layout, 1 means force 2 clients to always split vertically */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayspacing = 1;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray             = 0;   /* 0 means no systray */
static const char *fonts[]               = { "Monoid:size=9" };
static const unsigned int baralpha       = 0xff;
static const unsigned int borderalpha    = 0xff;
static const char col_base00[]      = "#1f2022";
static const char col_base02[]      = "#444155";
static const char col_base04[]      = "#b8b8b8";
static const char col_base0C[]      = "#2d9574";
static const char col_base0D[]      = "#4f97d7";
static const char *colors[][3]      = {
	/*               fg          bg          border   */
	[SchemeNorm] = { col_base04, col_base00, col_base02 },
	[SchemeSel]  = { col_base0D, col_base00, col_base0C },
};
static const unsigned int alphas[][3] = {
	/*               fg      bg        border     */
	[SchemeNorm] = { OPAQUE, baralpha, borderalpha },
	[SchemeSel]  = { OPAQUE, baralpha, borderalpha },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 *  WM_WINDOW_ROLE(STRING) = role
	 */
	/* class            role                          instance     title   tags mask  switchtag  iscentered   isfloating   monitor */
	{ "Gimp",           NULL,                         NULL,        NULL,   1 << 4,    1,         0,           1,           -1 },	
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */

#include "vanitygaps.c"

static const int layoutaxis[] = {
	SPLIT_VERTICAL,   /* layout axis: 1 = x, 2 = y; negative values mirror the layout, setting the master area to the right / bottom instead of left / top */
	TOP_TO_BOTTOM,    /* master axis: 1 = x (from left to right), 2 = y (from top to bottom), 3 = z (monocle), 4 = grid */
	TOP_TO_BOTTOM,    /* stack axis:  1 = x (from left to right), 2 = y (from top to bottom), 3 = z (monocle), 4 = grid */
};

static const Layout layouts[] = {
	/* symbol	arrange function */
	{ "[]=",	flextile }, /* first entry is default */
	{ ":::",	gaplessgrid },
	{ "𝍖𝍖𝍖",	grid },
	{ "[M]",	monocle },
	{ "=M=",	centeredmaster },
	{ "⧉⟧⧠",	NULL },    /* no layout function means floating behavior */
	{ "⧉M⧠",	centeredfloatingmaster },
	{ "⚎⚎⚎",	bstack },
	{ "☰☰☰",	bstackhoriz },
	{ "---",	horizgrid },
	{ "###",	nrowgrid },
	{ "⟦@⟧",	spiral },
	{ "⟦➘⟧",	dwindle },
	{ "D[]",	deck },
	{ "[]=",	tile },
	{ NULL,		NULL },
};

/* key definitions */
#define MODKEY Mod1Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, NULL };

static Key keys[] = {
	/* modifier                     key        function           argument */
	{ MODKEY,                       0xff51,    focusstack,        {.i = +1 } },
	{ MODKEY,                       0xff53,    focusstack,        {.i = -1 } },
	{ MODKEY|Mod4Mask,              0xff51,    rotatestack,       {.i = +1 } },
	{ MODKEY|Mod4Mask,              0xff53,    rotatestack,       {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,        {.i = +1 } },
	{ MODKEY,                       XK_u,      incnmaster,        {.i = -1 } },
	{ MODKEY,                       0xff54,    setmfact,          {.f = -0.05} },
	{ MODKEY,                       0xff52,    setmfact,          {.f = +0.05} },
	{ MODKEY|ShiftMask,             0xff54,    setcfact,          {.f = +0.25} },
	{ MODKEY|ShiftMask,             0xff52,    setcfact,          {.f = -0.25} },
	{ MODKEY|ShiftMask,             XK_o,      setcfact,          {.f =  0.00} },
	{ MODKEY,                       XK_m,      zoom,              {0} },
	{ MODKEY,                       XK_q,      killclient,        {0} },
	{ MODKEY,                       XK_w,      setflexlayout,     {.i = 293 } }, // centered master layout
	{ MODKEY,                       XK_e,      setflexlayout,     {.i = 273 } }, // bstackhoriz layout
	{ MODKEY,                       XK_r,      setflexlayout,     {.i = 272 } }, // bstack layout
	{ MODKEY,                       XK_t,      setflexlayout,     {.i = 261 } }, // default tile layout
	{ MODKEY,                       XK_g,      setflexlayout,     {.i =   7 } }, // grid layout
	{ MODKEY|ControlMask,           XK_w,      setflexlayout,     {.i = 263 } }, // tile + grid layout
	{ MODKEY|ControlMask,           XK_e,      setflexlayout,     {.i = 262 } }, // deck layout
	{ MODKEY|ControlMask,           XK_r,      setflexlayout,     {.i =   6 } }, // monocle layout
	{ MODKEY|ControlMask,           XK_g,      setflexlayout,     {.i = 257 } }, // columns (col) layout
	{ MODKEY,                       XK_space,  setlayout,         {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating,    {0} },
	{ MODKEY,                       XK_f,      togglefullscreen,  {0} },
	{ MODKEY,                       XK_0,      view,              {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,               {.ui = ~0 } },
	TAGKEYS(                        XK_1,                         0)
	TAGKEYS(                        XK_2,                         1)
	TAGKEYS(                        XK_3,                         2)
	TAGKEYS(                        XK_4,                         3)
	TAGKEYS(                        XK_5,                         4)
	TAGKEYS(                        XK_6,                         5)
	TAGKEYS(                        XK_7,                         6)
	TAGKEYS(                        XK_8,                         7)
	TAGKEYS(                        XK_9,                         8)
	TAGKEYS(                        XK_F1,                        0)
	TAGKEYS(                        XK_F2,                        1)
	TAGKEYS(                        XK_F3,                        2)
	TAGKEYS(                        XK_F4,                        3)
	TAGKEYS(                        XK_F5,                        4)
	TAGKEYS(                        XK_F6,                        5)
	TAGKEYS(                        XK_F7,                        6)
	TAGKEYS(                        XK_F8,                        7)
	TAGKEYS(                        XK_F9,                        8)
	{ MODKEY|ShiftMask,             XK_q,      quit,              {0} },
	{ MODKEY|ControlMask,           XK_t,      rotatelayoutaxis,  {.i = 0} },    /* flextile, 0 = layout axis */
	{ MODKEY|ControlMask,           XK_Tab,    rotatelayoutaxis,  {.i = 1} },    /* flextile, 1 = master axis */
	{ MODKEY|ControlMask|ShiftMask, XK_Tab,    rotatelayoutaxis,  {.i = 2} },    /* flextile, 2 = stack axis */
	{ MODKEY|ControlMask,           XK_Return, mirrorlayout,      {0} },         /* flextile, flip master and stack areas */
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask         button          function        argument */
	{ ClkLtSymbol,          0,                 Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,                 Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkLtSymbol,          0,                 Button4,        cyclelayout,    {.i = +1 } },
	{ ClkLtSymbol,          0,                 Button5,        cyclelayout,    {.i = -1 } },
	{ ClkWinTitle,          0,                 Button2,        zoom,           {0} },	
	{ ClkClientWin,         MODKEY,            Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY|Mod4Mask,   Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,            Button3,        resizemouse,    {0} },
	{ ClkClientWin,         MODKEY,            Button4,        rotatestack,    {.i = +1 } },
	{ ClkClientWin,         MODKEY,            Button5,        rotatestack,    {.i = -1 } },
	{ ClkClientWin,         MODKEY,            Button2,        zoom,           {0} },
	{ ClkClientWin,         MODKEY|Mod4Mask,   Button4,        cyclelayout,    {.i = -1 } },
	{ ClkClientWin,         MODKEY|Mod4Mask,   Button5,        cyclelayout,    {.i = +1 } },
	{ ClkTagBar,            0,                 Button1,        view,           {0} },
	{ ClkTagBar,            0,                 Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,            Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,            Button3,        toggletag,      {0} },
};
