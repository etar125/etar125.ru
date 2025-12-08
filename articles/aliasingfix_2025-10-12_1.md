# Фиксим сглаживание в Java Swing приложениях
### 12.10.2025

Захотел поиграть в infdev и alpha Minecraft, и скачал себе Betacraft.  
Запускаю, а тут такая картина:  

![Несглаженный текст](https://media.etar125.ru/bcb_1210.png)

Решается всё очень просто: добавьте к параметрам запуска (перед -jar) `-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true`.  
Чтобы постоянно это не прописывать, добавьте в свой `.bashrc`:
```
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
```

Результат:  

![Сглаженный текст](https://media.etar125.ru/bca_1210.png)
