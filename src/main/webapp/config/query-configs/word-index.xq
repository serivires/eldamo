import module namespace c = "common.xq" at "common.xq";

declare variable $id external;
declare variable $pubmode external;
declare variable $lang := /*//language[@id=$id];
declare variable $lang-name := $lang/@name/string();

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Eldamo : {$lang-name} Words</title>
<link type="text/css" rel="stylesheet" href="../../css/global.css" />

<script src="../../js/glaemscribe.min.js"></script>
<script src="../../js/tengwar_ds.cst.js"></script>
<script src="../../js/tengwar_ds_eldamar.cst.js"></script>
<script src="../../js/quenya.glaem.js"></script>
<script src="../../js/sindarin-beleriand.glaem.js"></script>
<script src="../../js/sindarin-classical.glaem.js"></script>
<script src="../../js/transcribe.js"></script>

</head>
<body>
<table id="nav-table" class="nav-table"><tr><td>
    [<a href="../../index.html">Home</a>] »
    [<a href="../languages/index.html">Languages</a>] »
    [<a href="../language-pages/lang-{$id}.html">{$lang-name}</a>]
</td></tr></table>
<table id="neo-nav-table" class="neo-nav-table"><tr><td>
    [<a href="../../index.html">Home</a>] »
    [<a href="../languages/index.html">Languages</a>] »
    [<a href="../language-pages/lang-{$id}.html">{$lang-name}</a>]
</td></tr></table>
<hr/>
<h1>{$lang-name} Words</h1>
{xdb:html($lang/words/string())}
<hr/> { 
let $words := c:lang-words(/*, $id)
let $word-list := $words
        [not(ends-with(c:get-speech(.), '-name'))]
        [not(c:get-speech(.)='text')]
        [not(c:get-speech(.)='phrase' or c:get-speech(.)='text')]
        [not(c:get-speech(.)='grammar')]
        [not(starts-with(c:get-speech(.), 'phone'))]
        [not(c:get-speech(.)='root')]
return (
<dl> {
for $word in $word-list
let $alt-lang := c:alt-lang($word)
let $neo-lang := if ($id = 'nq' or $id = 'ns' or $id = 'np') then true() else false()
let $normalize := if ($id = 'nq') then true() else false()
order by if ($neo-lang)
    then c:normalize-for-sort(c:normalize-spelling($word/@v))
    else c:normalize-for-sort($word/@v)
return (
    <dt>
        { if (
            $neo-lang and ($word/deprecated
            or $word/@gloss='[unglossed]'
            or contains($word/@mark, '-') or contains($word/@mark, '|'))
          ) then <span>⚠️</span> else () }
        { if (not($neo-lang)) then () else (
            let $lang-list := (c:print-lang2($word), for $w in $word/ancestor-or-self::word[last()]//word[combine[@l=$word/@l and @v=$word/@v]] return c:print-lang2($w))
            return concat(string-join($lang-list, ', '), ' ')
        ) }
        { if ($alt-lang) then concat('[', $alt-lang, if (c:is-primitive($word)) then ']' else '] ') else () }
        { if ($word/see) then c:print-word($word, <control style="bold" normalize="{$normalize}"/>)
          else c:print-word($word, <control style="bold" show-link="y" normalize="{$normalize}"/>) }
        { if ($word/@stem) then <span> (<b>{if ($normalize) then c:normalize-spelling($word/@stem) else $word/@stem/string()}</b>)</span> else () }
        { if ($word/@tengwar) then <span> [<b>{$word/@tengwar/string()}</b>]</span> else () }
        { if (($id = 'ns' or $id = 'nq') and
             not($word/@speech = 'grammar' or $word/@speech = 'text' or contains($word/@speech, 'phone')) and
             not($word/@l='q' and starts-with($word/@v, '-d'))
            )
            then ( (: ', DISABLED TENGWAR ',
                <span class="transcribe"
                    data-value="{
                        if ($word/@tengwar='ñ') then
                            translate($word/@v/lower-case(.), 'n', 'ñ') 
                        else if ($word/@tengwar='þ') then
                            translate($word/@v/lower-case(.), 's', 'þ') 
                        else $word/@v/lower-case(.)
                    }" data-lang="{$word/@l}"></span>
            , ' ' :) ) else ()}
        { c:print-speech($word) }
        { c:print-gloss($word) }
        { if ($word/see and not($neo-lang and $word/deprecated/@v))
          then (' see ', c:print-word(c:get-word($word/see),
            <control show-link="y" normalize="{$normalize}"> {
              if ($neo-lang or c:get-lang($word) != $word/see/@l) then attribute show-lang {'y'} else ()
            } </control>
        )) else () } 
        { if ($neo-lang and $word/deprecated/@v) then ('; see instead:',
            for $deprecated in $word/deprecated return <dd class="see-instead"> {
                c:print-word(c:get-word($deprecated), <control show-link="y" normalize="{$normalize}" show-lang="y" show-gloss="y"/>)
            } </dd>
        )  else () } 
    </dt>
) } </dl>,
if ($pubmode != 'false') then () else (
let $unglossed := $word-list[not(c:get-gloss(.))]
return (
if (not($unglossed)) then () else (
<h3>Unglossed [{count($unglossed)}]</h3>,
<dl> {
for $word in $unglossed
order by c:normalize-for-sort($word/@v)
return <dt>{c:print-word($word, <control style="bold" show-link="y"/>) }</dt>
} </dl>
) ) 
) ) }
</body>
</html>