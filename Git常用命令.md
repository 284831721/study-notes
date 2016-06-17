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
#### 未切换资源订单统计
```sql
SELECT
	*, round(
		foo.pay_order_count * 100 /(SELECT count(1) FROM main_order where date(create_time) = date),
		4
	) AS 该店铺支付订单占总比,
	CASE
WHEN foo.pay_order_count = 0 THEN
	0
ELSE
	round(
		foo.close_after_pay_order_count * 100 / foo.pay_order_count,
		4
	)
END AS 关闭订单占支付订单总比
FROM
	(
		SELECT
			CASE
		WHEN tmp.supplier_id = 18024 THEN
			'虚拟自建'
		WHEN tmp.supplier_id = 17800 THEN
			'承载库'
		ELSE
			'接口接入'
		END AS source_type,
		tmp.supplier_id,
		tmp.shop_name,
		tmp. SOURCE,
		DATE (tmp. DATE) AS DATE,
		COUNT (tmp.main_order_id) AS total_order_count,
		SUM (
			CASE
			WHEN tmp.pay_time IS NULL THEN
				0
			ELSE
				1
			END
		) AS pay_order_count,
		SUM (
			CASE
			WHEN tmp.status = 12 THEN
				1
			ELSE
				0
			END
		) AS complete_order_count,
		SUM (
			CASE
			WHEN tmp.status = 12 THEN
				0
			ELSE
				1
			END
		) AS close_order_count,
		SUM (
			CASE
			WHEN tmp.status != 12
			AND tmp.pay_time IS NOT NULL THEN
				1
			ELSE
				0
			END
		) AS close_after_pay_order_count
	FROM
		(
			SELECT
				fo.main_order_id,
				fo.supplier_id,
				fo.flight_more_info -> 'source' AS SOURCE,
				si.shop_name,
				mo.pay_time,
				mo.status,
				DATE (mo.create_time) AS DATE
			FROM
				main_order mo
			INNER JOIN flight_order fo ON mo. ID = fo.main_order_id
			AND (
				fo.origin_supplier != 0
				and fo.origin_supplier IS not NULL
			)
			INNER JOIN b2c_supplier_info si ON supplier_id = si. ID -- AND DATE (mo.create_time) = DATE '$TODAY' - 1
			GROUP BY
				DATE (mo.create_time),
				supplier_id,
				shop_name,
				fo.flight_more_info -> 'source',
				fo.main_order_id,
				mo.pay_time,
				mo.status
		) AS tmp
	GROUP BY
		DATE (tmp. DATE),
		tmp.supplier_id,
		tmp.shop_name,
		tmp. SOURCE
	) AS foo
ORDER BY
	foo.DATE DESC
```
```sql
CREATE INDEX "main_order_create_time_status_idx" ON "public"."main_order" USING btree (create_time);
```