# Taggable for UITextView

Written by [Phat](https://www.facebook.com/phthphat)

## How to use

### Implement dataSource (require)

```Swift
class MainVC: UIViewController {
    let tagTextView: TaggableTextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tagTextView.dataSourceTag = self
    }
}
extension MainVC: TaggableDataSource {
    func tagFunction(_ sender: Any, setAutoLayoutFor hoverView: UIView) {
        //Do anything with HoverView, you can set frame, or auto layout for this
    }
    
    func colorOfTaggedName(sender: Any) -> UIColor {
        //Tag text color will be highlighted
        return .purple
    }
    
    func tagFunction(_ sender: Any, registerCellFor tableView: UITableView) -> (AnyClass, String) {
        //Return a tupple (CellClass, CellId)
        return (UITableViewCell.self, "CellID")
    }
}
```

To configure cell, please edit the `TaggableTextView.swift`, it's abit inconvenience:

```Swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        cell?.textLabel?.text = self.filteredData[indexPath.row].name
        cell?.backgroundColor = .red
        return cell ?? UITableViewCell()
}
```

## Attention
### UITextViewDelegate
If you want to use `delegate` of UITextView in `TaggableTextView`, please execute `TaggableTextView.textViewDidChange(_ textView: UITextView)` addition. If you don't, the taggable function will be not available
```Swift
class MainVC {
    let tagTextView = TaggableTextView()

    override viewDidLoad() {
        super.viewDidLoad()
        tagTextView.delegate = self
    }
}

extension MainVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        tagTextView.textViewDidChange(_ textView: textView)
        //Do your custom code here
    }
}
``` 
### TaggableDelegate
Similar to `UITextViewDelegate`