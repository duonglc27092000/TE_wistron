# -*- coding: utf-8 -*-
"""
CheckError.py

用途：
  从设备日志文件中提取满足以下条件的记录：
    - 行中出现 "Status: <状态>"，其中 <状态> 可配置（如 Error, Unknown 等）
    - 使用最近一次出现的 "Device name:" 作为该状态行对应的设备名
  可选择排除某个设备名（默认排除：HID-compliant touch screen）或不排除。

新增特性：
  - 通过 --include-status 可以指定需要输出的状态列表，例如：
      --include-status Error Unknown
  - 通过 --no-exclude-name 可以关闭设备名排除逻辑，导出所有匹配状态。

使用示例：
  只导出 Status 为 Unknown 且设备名不是 HID-compliant touch screen 的记录：
    python CheckError.py --input Device.log --output unknown_not_hid.csv --include-status Unknown

  同时导出 Error 与 Unknown（设备名不过滤）：
    python CheckError.py --input Device.log --output errors_unknown_all.csv --include-status Error Unknown --no-exclude-name

作者：M365 Copilot
"""

import argparse
import csv
import sys


def parse_args():
    parser = argparse.ArgumentParser(description="Extract specified status lines with their device names from a device log.")
    parser.add_argument("--input", required=True, help="输入的日志文件路径")
    parser.add_argument("--output", required=True, help="输出的 CSV 文件路径")
    parser.add_argument(
        "--include-status",
        nargs="+",
        default=["Error"],
        help="要包含的状态（可多个），默认：Error。例如：Error Unknown",
    )
    parser.add_argument(
        "--exclude-name",
        default="HID-compliant touch screen",
        help="需要排除的设备名（默认：HID-compliant touch screen）",
    )
    parser.add_argument(
        "--no-exclude-name",
        action="store_true",
        help="不排除任何设备名（忽略 --exclude-name 设置）",
    )
    return parser.parse_args()


def extract(input_path, output_path, include_statuses, exclude_name, no_exclude_name=False):
    try:
        with open(input_path, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()
    except Exception as e:
        print(f"读取日志文件失败：{e}")
        sys.exit(1)

    # 统一大小写比较（状态大小写敏感按日志原样，但这里采用不敏感匹配）
    include_lower = {s.lower() for s in include_statuses}

    results = []
    current_device_name = None

    for idx, line in enumerate(lines, start=1):
        l = line.strip()
        if l.startswith("Device name:"):
            current_device_name = l.split(":", 1)[1].strip()
            current_device_name1 = l
        elif l.startswith("Status:"):
            # 提取状态值（去掉前缀）
            status_val = l.split(":", 1)[1].strip()
            if status_val.lower() in include_lower:
                # 设备名必须已知
                if current_device_name is None:
                    continue
                # 设备名排除逻辑
                if not no_exclude_name and current_device_name == exclude_name:
                    continue
                results.append({
                    "line_number": idx,
                    "device_name": current_device_name1,
                    "status": status_val,
                })

    # 写出 CSV
    try:
        with open(output_path, "w", newline="", encoding="utf-8") as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=["line_number", "device_name", "status"])
            writer.writeheader()
            for row in results:
                writer.writerow(row)
    except Exception as e:
        print(f"写入 CSV 失败：{e}")
        sys.exit(1)

    return {
        "total_lines": len(lines),
        "total_matches": len(results),
        "output_file": output_path,
        "include_statuses": include_statuses,
        "exclude_name": None if no_exclude_name else exclude_name,
    }


if __name__ == "__main__":
    args = parse_args()
    summary = extract(
        args.input,
        args.output,
        args.include_status,
        args.exclude_name,
        args.no_exclude_name,
    )
    print(
        f"Total: {summary['total_lines']} row,match {summary['total_matches']} item.\n"
        f"Include status:{', '.join(summary['include_statuses'])};"
        f"Except device:{summary['exclude_name'] if summary['exclude_name'] is not None else '(None)'}\n"
        f"Output file:{summary['output_file']}"
    )
