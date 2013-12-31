% Level is a Function of Experience

If you're making a role-playing game,
you probably have entities that level up through experience points or some other counter that represents the progress through the game made by the entity.
You also probably have to fiddle with the XP and level variables every time the character levels up,
and that can be fragile and annoying.
Here's a simple and robust way to represent a character's level without writing too much brittle code.

## The Experience Table

Imagine a character needs 50 XP per level-up more than the last level-up to reach the next one.
At level 1 he would need to reach 50 XP to attain level 2,
and 100 XP from there to attain level 3,
for a total of 150 XP.
That can be expressed with this formula: \\(XP = 25 \\times (L - 1) \\times L\\).
The progression for the first 10 levels is summarized here:

<table>
<tr><th>Level</th><th>Experience</th><th>Total</th></tr>
<tr><td>1</td><td>0</td><td>0</td></tr>
<tr><td>2</td><td>50</td><td>50</td></tr>
<tr><td>3</td><td>100</td><td>150</td></tr>
<tr><td>4</td><td>150</td><td>300</td></tr>
<tr><td>5</td><td>200</td><td>500</td></tr>
<tr><td>6</td><td>250</td><td>750</td></tr>
<tr><td>7</td><td>300</td><td>1050</td></tr>
<tr><td>8</td><td>350</td><td>1400</td></tr>
<tr><td>9</td><td>400</td><td>1800</td></tr>
<tr><td>10</td><td>450</td><td>2250</td></tr>
</table>

The trouble when implementing this usually arises when you need to do things like
roll over extra XP after a level-up toward the next
or award multiple level-ups after a really big XP award.
The code for awarding some XP to an entity and handling those cases might look like this:

``` python
def xp_for_level_up(level):
    return 25 * (level - 1) * level
    
def award_xp(entity, xp):
    entity.xp += xp
    while entity.xp >= xp_for_level_up(entity.level):
        entity.xp -= xp_for_level_up(entity.level)
        entity.level += 1
```

In this scenario two variables need to be maintained,
one for the experience and one for the level.
They are only kept in agreement by code that handles them,
which can be both inflexible and prone to bugs.
A more robust way to handle this without loops and updating too many variables emerges after noticing that the numbers in the Total column follow an arithmetic progression!
*Mathematical!*
Recognizing this will let you treat entities' levels as functions of their experience instead of as extra variables independent of it.
The level can be derived from the XP by doing a little bit of algebra,
keeping in mind the quadratic equation:

\\\[
XP = 25 \\times (L - 1) \\times L \\\\
XP = 25 \\times (L^2 - L) \\\\
0 = 25L^2 - 25L - XP \\\\
L = \\frac{25 + \\sqrt{(-25)^2 + 4 \\times 25 \\times XP}}{2 \\times 25} \\\\
L = \\bigg\\lfloor{\\frac{25 + \\sqrt{625 + 100 \\times XP}}{50}}\\bigg\\rfloor
\\\]

Here's how those two functions might look in code:

``` python
import math

def xp(level):
    "Return how much XP is required to reach ``level``"
    return 25 * (level - 1) * level
    
def level(xp):
    "Return what level a character with ``xp`` XP is at"
    return math.floor((25 + math.sqrt(625 + 100 * xp)) / 50)
```

Making the level a function of XP is now less bug-prone,
because only a single variable needs to be changed.
This method also enables a wider range of in-game mechanics,
like easily granting temporary XP boosts,
or even permanently rolling XP backward.
