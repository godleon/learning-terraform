透過 `terraform graph` 可以產生出可用來繪製關係圖的 DOT 語法

```bash
$ $ terraform graph
digraph {
	compound = "true"
	newrank = "true"
	subgraph "root" {
		"[root] aws_instance.example" [label = "aws_instance.example", shape = "box"]
		"[root] aws_security_group.instance" [label = "aws_security_group.instance", shape = "box"]
		"[root] provider.aws" [label = "provider.aws", shape = "diamond"]
		"[root] aws_instance.example" -> "[root] aws_security_group.instance"
		"[root] aws_security_group.instance" -> "[root] provider.aws"
		"[root] meta.count-boundary (EachMode fixup)" -> "[root] aws_instance.example"
		"[root] provider.aws (close)" -> "[root] aws_instance.example"
		"[root] root" -> "[root] meta.count-boundary (EachMode fixup)"
		"[root] root" -> "[root] provider.aws (close)"
	}
}
```

可以把上面的語法拿到 [Graphviz 的網站](https://dreampuf.github.io/GraphvizOnline)貼上，就可以看到各個物件的關係圖