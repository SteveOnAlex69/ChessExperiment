using Godot;
using System;
using System.Text;

public partial class Utility : Node
{
	private static double abs(double a){
		return Math.Abs(a);
	}
	private static double max(double a, double b){
		return Math.Max(a, b);
	}
	private static double min(double a, double b){
		return Math.Min(a, b);
	}
	
	public static double chebyshev_distance(Vector2 a, Vector2 b){
		return max(abs(a.X - b.X), abs(a.Y - b.Y));	
	}
	public static double manhattan_distance(Vector2 a, Vector2 b){
		return abs(a.X - b.X) + abs(a.Y - b.Y);
	}
		
	public static int vector_to_cell_index(Vector2 p){
		return (int)(p.X * 8 + p.Y);
	}
	public static Vector2 int_to_cell_vector(int i){
		return new Vector2(i / 8, i % 8);
	}
	public static string vector_to_cell_notation(Vector2 p){
		int x = (int) p.X, y = (int) p.Y;
		StringBuilder ans = new StringBuilder();
		ans.Append((char)('a' + x));
		ans.Append((char)('1' + y));
		return ans.ToString();
	}
	public static string int_to_cell_notation(int i){
		return vector_to_cell_notation(int_to_cell_vector(i));
	}
	public static Vector2 cell_notation_to_vector(string s){
		return new Vector2(s[0] - 'a', s[1] - '1');
	}
	public static int cell_notation_to_int(string s){
		Vector2 cur = cell_notation_to_vector(s);
		return (int)(cur.X * 8 + cur.Y);
	}
	public static bool is_upper_case(string s){
		return s == s.ToUpper();
	}
	public static bool is_king_distance(Vector2 a, Vector2 b){
		return chebyshev_distance(a, b) <= 1;
	}
	public static bool is_knight_distance(Vector2 a, Vector2 b){
		return chebyshev_distance(a, b) == 2 && manhattan_distance(a, b) == 3;
	}
	public static bool is_rook_distance(Vector2 a, Vector2 b){
		return chebyshev_distance(a, b) == manhattan_distance(a, b);
	}
	public static bool is_bishop_distance(Vector2 a, Vector2 b){
		return chebyshev_distance(a, b) * 2 == manhattan_distance(a, b);
	}
	public static bool is_pawn_distance(Vector2 a, Vector2 b){
		return (manhattan_distance(a, b) <= 2) && (a.Y == b.Y);
	}
	
	public static string make_string_from_arr(Godot.Collections.Array arr){
		StringBuilder ans = new StringBuilder();
		foreach (var i in arr){
			ans.Append(i);
		}
		return ans.ToString();
		
	}
	public static string fein(string str){
		StringBuilder ans = new StringBuilder(new string('.', 64));
		int i = 7, j = 0;
		foreach (var c in str){
			if (c == '/'){
				i--;
				j = 0;
			}
			else{
				if (Char.IsNumber(c)){
					int cur = c - '0';
					j += cur;
				}
				else{
					ans[i*8+j] = c;
					j++;
				}
			}
		}
		return ans.ToString();
	}
}
