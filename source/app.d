import std.stdio,
       std.conv,
       std.range,
       std.string,
       std.getopt,
       std.algorithm.comparison,
       std.algorithm.iteration;
import eastasianwidth;

const string dman =
`    t    _   _
     t  (_) (_)
       /______ \
       \\(e(e \/
        | | | |
        | |_| |
       /______/
         <   >
        (_) (_)
`;
const string[] eyes = ["=", "X", "$", "@", "*", "-", "O", "."];
const string[] usage =[
  `d-man{say,think} version 0.0.2, (c) 2016 @simd_nyan`,
  `Usage: d-man{say,think} [-bdgpstwy] [-h] [-n] [-W wrapcolumn] [message]`
];
version (say)
{
  const string thought = `\`;
  const string[] baloons = [
    "< ", "< ", "< ",  " >\n",  " >\n", " >\n",
    "/ ", "| ", "\\ ", " \\\n", " |\n", " /\n"
  ];
}
version(think)
{
  const string thought = `o`;
  const string[] baloons = [
    "( ", "( ", "( ", " )\n", " )\n", " )\n",
    "( ", "( ", "( ", " )\n", " )\n", " )\n"
  ];
}

class Message
{
  string[] lines;
  bool  wordwrap;
  ulong wrapcolumn;
  ulong max_length = 0;

  this(bool wordwrap, ulong wrapcolumn)
  {
    this.wordwrap   = wordwrap;
    this.wrapcolumn = wordwrap ? ulong.max : wrapcolumn;
  }

  void add(string line)
  {
    ulong line_length = displayWidth(line, AmbiguousCharWidth.wide);
    max_length = min(max(max_length, line_length), wrapcolumn);
    string t_line = "";
    foreach(s; array(line)) {
      if (displayWidth(t_line ~ to!string(s), AmbiguousCharWidth.wide) > max_length){
        lines ~= t_line;
        t_line = "";
      }
      t_line ~= s;
    }
    lines ~= t_line;
  }

  void print()
  {
    write_line('_');
    foreach(int n, string o; lines){
      int b = ((lines.length > 1) ?  6 : 0) + (n > 0) + (n == lines.length - 1);
      write(baloons[b]);
      write(o);
      write(" ".repeat(to!size_t(max_length - displayWidth(o, AmbiguousCharWidth.wide))).joiner);
      write(baloons[b + 3]);
    }
    write_line('-');
  }

  void write_line(char c)
  {
    write(" ");
    for(int i; i < max_length + 2; i++)
      write(c);
    writeln();
  }

}

void main(string[] args){

  bool   help       = false;
  bool   wordwrap   = false;
  ulong  wrapcolumn = 40;
  bool[] eye_flags  = [false, false, false, false, false, false, false, false];
  string eye        = "O";
  getopt(args,
    std.getopt.config.passThrough,
    std.getopt.config.caseSensitive,
    "h|help",  &help,
    "n",  &wordwrap,
    "W",  &wrapcolumn,
    "b",  &eye_flags[0],
    "d",  &eye_flags[1],
    "g",  &eye_flags[2],
    "p",  &eye_flags[3],
    "s",  &eye_flags[4],
    "t",  &eye_flags[5],
    "w",  &eye_flags[6],
    "y",  &eye_flags[7],
    "e",  &eye
  );

  if (help)
    wordwrap = true;

  for(int i = 0; i < eye_flags.length; i++)
    if (eye_flags[i])
      eye = eyes[i];

  auto output = new Message(wordwrap, wrapcolumn);
  ulong max_length = 0;
  if (help)
  {
    output.add(usage[0]);
    output.add(usage[1]);
  }
  else
  {
    if (args.length > 1)
      output.add(args[1..$].join(' '));
    else
    {
      string line;
      while ((line = stdin.readln()) !is null)
        output.add(line.chomp);
    }
  }

  output.print();

  writeln(dman.tr("t", thought).tr("e", eye));
}

