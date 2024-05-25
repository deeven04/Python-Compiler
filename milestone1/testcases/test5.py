class Node:
    def __init__(self, data):
        self.data = data
        self.left = None
        self.right = None

def insert(root, key):
    if root is None:
        return Node(key)
    else:
        if root.data < key:
            root.right = insert(root.right, key)
        else:
            root.left = insert(root.left, key)
    return root

def inorder(root):
    if root:
        inorder(root.left)
        print(root.data, end=' ')
        inorder(root.right)

def minValueNode(node):
    current = node
    while current.left:
        current = current.left
    return current

def deleteNode(root, key):
    if root is None:
        return root
    if key < root.data:
        root.left = deleteNode(root.left, key)
    elif key > root.data:
        root.right = deleteNode(root.right, key)
    else:
        if root.left is None:
            temp = root.right
            root = None
            return temp
        elif root.right is None:
            temp = root.left
            root = None
            return temp
        temp = minValueNode(root.right)
        root.data = temp.data
        root.right = deleteNode(root.right, temp.data)
    return root

def search(root, key):
    if root is None or root.data == key:
        return root
    if root.data < key:
        return search(root.right, key)
    return search(root.left, key)

root = None
root = insert(root, 50)
root = insert(root, 30)
root = insert(root, 20)
root = insert(root, 40)
root = insert(root, 70)
root = insert(root, 60)
root = insert(root, 80)

print("Inorder traversal of the given tree:")
inorder(root)

print("nDelete 20")
root = deleteNode(root, 20)
print("Inorder traversal of the modified tree:")
inorder(root)

print("Delete 30")
root = deleteNode(root, 30)
print("Inorder traversal of the modified tree:")
inorder(root)

print("Delete 50")
root = deleteNode(root, 50)
print("Inorder traversal of the modified tree:")
inorder(root)

if __name__ == "__main__":
  main()
