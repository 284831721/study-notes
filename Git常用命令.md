#### Git 常用命令
---
- 删除远程分支
``` git push origin --delete branchName ```
``` git push origin :branchName```

#### Linux常用命令
---
- 显示当前目录及子目录下匹配某个文件格式的文件数
``` l -R | grep \\.java |wc -l  ```
- 查找当时目录及子目录下包含某字符串的文件列表，指定格式的文件里查找
``` grep -lr "String" . --include="*.java" ```
- 替换所有文件中的xxx为yyy
``` find . -name pom.xml -exec sed -i 's/xxx/yyy/g' {} + ```

##### 有限状态机开源框架
---
> [StatefulJ](http://www.statefulj.org/) 
> [Squirrel State Machine](https://github.com/hekailiang/squirrel)


### todo

- Camel RouteBuilder
- Spring securityContextHolder
- Spring webflow https://github.com/spring-projects/spring-
---
