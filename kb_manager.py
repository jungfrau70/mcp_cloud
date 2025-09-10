
import os
from pathlib import Path
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.screen import ModalScreen
from textual.widgets import DirectoryTree, Footer, Header, Markdown, Static, TextArea

KNOWLEDGE_BASE_PATH = "mcp_knowledge_base"

class FilteredDirectoryTree(DirectoryTree):
    def filter_paths(self, paths):
        return [path for path in paths if not path.name.startswith(".") and (path.is_dir() or path.name.endswith(".md"))]

class ViewFileModal(ModalScreen):
    """Modal screen to view a file."""

    BINDINGS = [
        Binding("escape", "close_modal", "Close"),
    ]

    def __init__(self, file_path: Path, **kwargs):
        super().__init__(**kwargs)
        self.file_path = file_path

    def compose(self) -> ComposeResult:
        content = ""
        try:
            with open(self.file_path, "r", encoding="utf-8") as f:
                content = f.read()
        except Exception as e:
            content = f"""# Error reading file

```
{e}
```"""

        yield Static(
            Markdown(content, id="markdown-view"),
            id="view-container"
        )

    def action_close_modal(self) -> None:
        self.app.pop_screen()

class EditFileModal(ModalScreen):
    """Modal screen to edit a file."""

    BINDINGS = [
        Binding("escape", "close_modal", "Close"),
        Binding("ctrl+s", "save_file", "Save"),
    ]

    def __init__(self, file_path: Path, **kwargs):
        super().__init__(**kwargs)
        self.file_path = file_path

    def compose(self) -> ComposeResult:
        yield Static(
            TextArea(id="text-area"),
            id="edit-container"
        )

    def on_mount(self) -> None:
        """Load the file content into the TextArea."""
        textarea = self.query_one(TextArea)
        try:
            with open(self.file_path, "r", encoding="utf-8") as f:
                textarea.text = f.read()
        except Exception as e:
            self.app.notify(f"Error loading file: {e}", severity="error")
            self.app.pop_screen()
        textarea.focus()

    def action_save_file(self) -> None:
        """Save the content of the TextArea to the file."""
        textarea = self.query_one(TextArea)
        try:
            with open(self.file_path, "w", encoding="utf-8") as f:
                f.write(textarea.text)
            self.app.notify("File saved successfully!", severity="information")
        except Exception as e:
            self.app.notify(f"Error saving file: {e}", severity="error")

    def action_close_modal(self) -> None:
        self.app.pop_screen()


class KbManagerApp(App):
    """A TUI for managing the knowledge base."""

    CSS_PATH = "kb_manager.css"
    BINDINGS = [
        Binding("q", "quit", "Quit"),
        Binding("e", "edit_file", "Edit"),
        Binding("v", "view_file", "View"),
        Binding("enter", "view_file", "View", show=False),
        # Add bindings for new, rename, delete later
    ]

    def compose(self) -> ComposeResult:
        """Create child widgets for the app."""
        yield Header()
        if not os.path.exists(KNOWLEDGE_BASE_PATH):
            os.makedirs(KNOWLEDGE_BASE_PATH)
        yield FilteredDirectoryTree(KNOWLEDGE_BASE_PATH, id="dir-tree")
        yield Footer()

    def on_mount(self) -> None:
        self.query_one(DirectoryTree).focus()

    def on_directory_tree_file_selected(self, event: DirectoryTree.FileSelected) -> None:
        """Called when the user clicks a file in the directory tree."""
        event.stop()
        self.action_view_file()

    def action_view_file(self) -> None:
        """Show the file view modal."""
        tree = self.query_one(DirectoryTree)
        if tree.cursor_node and tree.cursor_node.data.is_file:
            file_path = tree.cursor_node.data.path
            self.push_screen(ViewFileModal(file_path))

    def action_edit_file(self) -> None:
        """Show the file edit modal."""
        tree = self.query_one(DirectoryTree)
        if tree.cursor_node and tree.cursor_node.data.is_file:
            file_path = tree.cursor_node.data.path
            self.push_screen(EditFileModal(file_path))


if __name__ == "__main__":
    app = KbManagerApp()
    app.run()
