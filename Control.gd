extends Control
var grid = [];
var nt = 4;
onready var container = $GridContainer;
var size = 32;
var count = Vector2(20,20);
var debug = false;
onready var tween = $Tween;
func _ready():
	randomize();
	for y in range(0,count.y):
		grid.push_back([]);
		for x in range(0, count.x):
			var n = randi()%nt;

			var t = ColorRect.new();
			var component = 1.0/float(nt)*float(n);
			t.color = Color(component,component,component);
			t.rect_min_size= (Vector2(32,32));
			t.rect_position = Vector2(32*x,32*y);
			container.add_child(t);

			grid[y].push_back({"index":n,"instance":t});
	test();
func calculateMatches():
	var matches = [];

	#horizontal lines
	for y in range(0,count.y):
		var buffer = [[0,y]];
		var index2Match = grid[y][0].index;
		for x in range(1,count.x):
			if(index2Match == grid[y][x].index):
				buffer.push_back([x,y]);
			else:
				if(len(buffer) >= 3):
					matches.push_back(buffer);
				buffer = [[x,y]];
				index2Match = grid[y][x].index;
		if(len(buffer) >= 3):
			matches.push_back(buffer);

	#vertical lines
	for x in range(0,count.x):
		var buffer = [[x,0]];
		var index2Match = grid[0][x].index;
		for y in range(1,count.y):
			if(index2Match == grid[y][x].index):
				buffer.push_back([x,y]);
			else:
				if(len(buffer) >= 3):
					matches.push_back(buffer);
				buffer = [[x,y]];
				index2Match = grid[y][x].index;
		if(len(buffer) >= 3):
			matches.push_back(buffer);
	
	if(debug):
		print("FOUND MATCHES: ")
		for match_ in matches:
			print(match_);
			yield(get_tree().create_timer(1.0),"timeout");
			for elem in match_:
				grid[elem[1]][elem[0]].instance.color =Color.red;
	return matches;
func remove_matches(matches):
	for match_ in matches:
		for elem in match_:
			grid[elem[1]][elem[0]].instance.color =Color.transparent;
func isEmpty(x,y)->bool:
	return grid[y][x].instance.color == Color.transparent;
func swapObj(x,y,x1,y1):

	var obj1 = grid[y][x].instance
	var obj2 = grid[y1][x1].instance;

	var temp = grid[y][x];
	grid[y][x]= grid[y1][x1];
	grid[y1][x1]=temp;
	
	var tempP = obj1.rect_position;
	var tempP1 = obj2.rect_position;
	tween.interpolate_property(obj1,"rect_position", obj1.rect_position,obj2.rect_position,1.0,Tween.TRANS_CUBIC);
	tween.interpolate_property(obj2,"rect_position", obj2.rect_position,obj1.rect_position,1.0,Tween.TRANS_CUBIC);
	tween.start();
	yield(tween,"tween_all_completed");
	obj1.rect_position = tempP1;
	obj2.rect_position = tempP;

func getFalling():
	var fallen = true;
	while fallen:
		yield(get_tree().create_timer(0.5),"timeout");
		fallen = false;
		for x in range(0, count.x):
			var space = false;
			var spaceY = 0;
			for y in range(count.y-1, -1, -1):
				if(isEmpty(x,y)):
					spaceY = y;
					space = true;
				else:
					if(space):
						swapObj(x,y,x,spaceY);
						space = false;
						y=spaceY;
						fallen = true;
	
func addTiles():
	for x in range(0, count.x):
		for y in range(0, count.y):
			if(isEmpty(x,y)):
				print("EMPTY")
				var n = genNew(x,-1);
				grid[y][x] = n.duplicate();
				container.add_child(n.instance);
				tween.interpolate_property(n.instance,"rect_position",n.instance.rect_position,Vector2(32*x,32*y),1.0,Tween.TRANS_CUBIC);
				tween.start();
	yield(tween,"tween_all_completed")
func test():
	while true:
		var matches = calculateMatches();
		yield(get_tree().create_timer(1.0),"timeout")
		remove_matches(matches);
		yield(get_tree().create_timer(1.0),"timeout")
		yield(getFalling(),"completed");
		yield(addTiles(),"completed");

func genNew(x,y):
	var n = randi()%nt;
	var t = ColorRect.new();
	var component = 1.0/float(nt)*float(n);
	t.color = Color(component,component,component);
	t.rect_min_size= (Vector2(32,32));
	t.rect_position = Vector2(32*x,32*y);
	return {"index":n,"instance":t};
