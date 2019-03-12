$(".rich_text_editor").each(function (index, dom) {
    new Simditor({
      textarea: $(dom),
      placeholder: '',
      pasteImage: true,
      markdown: false,
      toolbar: ['markdown', 'title', 'bold', 'fontScale', 'color',  'emoji', 'ol', 'ul', 'blockquote', 'code', 'table',
      emoji: {
        imagePath: '/assets/emoji/'
      }
    });
});
