class TreeNode
{
    [string] $operator;
    [string] $value;
    
    [TreeNode] $left;
    [TreeNode] $right;

    TreeNode([TreeNode]$leftNode, [TreeNode]$rightNode, [string] $v, [string] $op)
    {
        $this.left = $leftNode;
        $this.right = $rightNode;

        $this.operator = $op;
        $this.value = $v;
    }
}

function GenerateRPN([string] $expression)
{
    $stack = New-Object System.Collections.Stack;
    $RPN = "";
    foreach ($ch in $expression.ToCharArray())
    {
        if($ch -eq " ")
        {
            continue;
        }

        if(IsBracket($ch))
        {
            if($ch -eq "(")
            {
                $stack.Push($ch);
            }
            else
            {
                while(-not ($stack.Peek() -eq "("))
                {
                    $RPN += $stack.Pop();
                }

               $t = $stack.Pop();
            }
        }
        elseif (isOp($ch))
        {
            while($stack.Count -gt 0 )
            {
                if((IsOpHigh($stack.Peek()) -ge IsOpHigh($ch)) -or (-not($stack.Peek() -eq "(")))
                {
                    $RPN += $stack.Pop();
                }
                else
                {
                    break;
                }
            }

            $stack.Push($ch);
        }
        else
        {
            $RPN += $ch;
        }
    }

    while($stack.Count -gt 0 )
    {
        $RPN += $stack.Pop();
    }
    
    return $RPN;
}

function IsOpHigh([char] $op)
{
    if ($op -eq '(') {return 0;} 
    if ($op -eq ')') {return 1;} 
    if (($op -eq '+') -or ($op -eq '-')) {return 2;} 
    if (($op -eq '*') -or ($op -eq '/')) {return 3;} 
    if ($op -eq '^') {return 4;}

    return -1;
}

function IsOp([char] $c)
{
    return ($c -eq '*') -or ($c -eq '/') -or ($c -eq '+') -or ($c -eq '-') -or ($c -eq '^');
}

function IsBracket([char] $c)
{
    return ($c -eq '(') -or ($c -eq ')');
}

function TreeBuild([string] $rpn)
{
    $stack = New-Object System.Collections.Stack;

    foreach($ch in $rpn.ToCharArray())
    {
        if(IsOp($ch))
        {
            $opRight = $stack.Pop();
            $opLeft = $stack.Pop();

            $newNode = [TreeNode]::new($opLeft, $opRight, "0", $ch);
            $stack.Push($newNode);
        }
        else
        {
            $newNode = [TreeNode]::new($null, $null, $ch, "0");
            $stack.Push($newNode);
        }
    }

    return $stack.Peek();
}

$Script:infixForm = "";
function Infix([TreeNode] $root)
{
    if($root -eq $null)
    {
        return;
    }

    $Script:infixForm += "(";

    Infix($root.left);

    if($root.value -eq "0")
    {
        $Script:infixForm+=$root.operator.ToString();
    }
    else
    {
         $Script:infixForm+=$root.value.ToString();
    }

    Infix($root.right);

    $Script:infixForm+=")";
}

$rawExpr = "((((A)+(B))*((C)+(D)))-(E))";

$expr = GenerateRPN($rawExpr);
$tree = TreeBuild($expr);
Infix($tree);

Write-Host "Raw expression $rawExpr" -ForegroundColor Black -BackgroundColor Yellow

if($rawExpr -eq $Script:infixForm)
{
    Write-Host "Expression from tree $Script:infixForm" -ForegroundColor Green -BackgroundColor Black
}
else
{
    Write-Host "Expression from tree $Script:infixForm"  -ForegroundColor Red -BackgroundColor Black
}
