class Vector
{
	Integer x, y;
	Vector()                     { this.x = 0;   this.y = 0;   }
	Vector(Integer x, Integer y) { this.x = x;   this.y = y;   }
	Vector(Vector v)             { this.x = v.x; this.y = v.y; }

	void add(Vector v)                         { this.x += v.x; this.y += v.y; }
	void add(Vector[] vs) {for (Vector v : vs) { this.x += v.x; this.y += v.y; } }
}