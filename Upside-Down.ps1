Function Upside-Down
{
    param ([Parameter(Mandatory=$true,ValueFromPipeline=$true)][string]$text)
    $Pairs  = 'aɐbqcɔdpeǝfɟgƃhɥiıjɾkʞllmɯnuoopdqbrɹsstʇunvʌwʍxxyʎzz.˙_‾())([]][{}}{?¿!¡,'''',  --'
    $Lookup = @{}
 
    # build the lookup table by stepping in intervals of 2 through the pairs
    for ($i=0; $i -lt $Pairs.Length; $i+=2)
    {
        $Lookup[$Pairs[$i]] = $Pairs[$i + 1]
    }
 
    # index all the text characters, backwards, and look them all up at once. -join it.
    -join $Lookup[$Text[($Text.Length - 1)..0]]
}