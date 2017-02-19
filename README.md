# Braces Be Gone

Get those pesky braces out of your face.

## Example

The input file, `Permuter.java`:
```java
public class Permuter
{
	private static void permute(int n, char[] a)
	{
		if (n == 0)
		{
			System.out.println(String.valueOf(a));
		}
		else
		{
			for (int i = 0; i <= n; i++)
			{
				permute(n-1, a);
				swap(a, n % 2 == 0 ? i : 0, n);
			}
		}
	}

	private static void swap(char[] a, int i, int j)
	{
		char saved = a[i];
		a[i] = a[j];
		a[j] = saved;
	}
}
```

Running `BracesBeGone.hs Permuter.java --tab-width 4` prints:
```java
public class Permuter                                {
	private static void permute(int n, char[] a)     {
		if (n == 0)                                  {
			System.out.println(String.valueOf(a))    ;}
		else                                         {
			for (int i = 0; i <= n; i++)             {
				permute(n-1, a)                      ;
				swap(a, n % 2 == 0 ? i : 0, n)       ;}}}

	private static void swap(char[] a, int i, int j) {
		char saved = a[i]                            ;
		a[i] = a[j]                                  ;
		a[j] = saved                                 ;}}

```

## Usage

```
% BracesBeGone.hs --help
Braces Be Gone

Usage: BracesBeGone.hs [FILE] [-o|--output FILE] [--tab-width TABWIDTH]
                       [--min-line-width LINEWIDTH] [--brace-chars CHARS]

Available options:
  -h,--help                Show this help text
  FILE                     Input source FILE (default: stdin)
  -o,--output FILE         Write output to FILE (default: stdout)
  --tab-width TABWIDTH     Count tab characters as TABWIDTH spaces (default: 8)
  --min-line-width LINEWIDTH
                           Align braces at least to LINEWIDTH (default: 0)
  --brace-chars CHARS      Use CHARS as braces (default: "{};")
```

You'll need `stack` to run this.

## Contact

Olle Fredriksson - https://github.com/ollef
