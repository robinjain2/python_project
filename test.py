def add(x, y):
    return x + y
 
def test_add():
    assert add(1, 2) == 3
    assert add(0, 1) == 1
    assert add(-1, 1) == 0
